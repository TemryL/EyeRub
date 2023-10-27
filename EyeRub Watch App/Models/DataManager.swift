//
//  DataManager.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import Foundation
import CoreMotion
import CoreML
import WatchKit
import HealthKit


struct MonitoredSample: Identifiable {
    var id = UUID()
    var label: String
    var date: String
}


class DataManager: ObservableObject {
    var wristLocation: String = "N/A"
    var crownOrientation: String = "N/A"
    var deviceName: String = "N/A"
    var deviceHardwarwVersion: String = "N/A"
    var allowPrediction: Bool = false
    
    var predictionManager: PredictionManager = PredictionManager()
    let motionManager: CMMotionManager = CMMotionManager()
    let device: WKInterfaceDevice = WKInterfaceDevice.current()
    
    var sensorDataArray: MLMultiArray = try! MLMultiArray(shape: [ModelConstants.windowSize, ModelConstants.numOfFeatures] as [NSNumber], dataType: MLMultiArrayDataType.float32)
    var currentIndexInPredictionWindow: Int = 0
    var numberLabeledActions: Int = 0
    var numberMonitoredActions: Int = 0
    var summaryCount: [String:Int] = ["Nothing":0,
                        "Eye rubbing":0,
                        "Eye touching":0,
                        "Glasses readjusting":0,
                        "Eating":0,
                        "Make up":0,
                        "Hair combing":0,
                        "Skin scratching":0,
                        "Teeth brushing":0]
    
    var label : String = "N/A"
    @Published var appMode = AppMode.notSet
    @Published var predictedLabel : String = "N/A"
    @Published var monitoredLabel : String = "notSet"
    @Published var monitoredSamples = [MonitoredSample]()
    @Published var isDataArrayFull: Bool = false
    @Published var showingLabelsView: Bool = false
    @Published var showingCountdownView: Bool = false

    
    // MARK: - Functions
    
    func formatUserInfo() {
        switch device.wristLocation {
        case .left:
            wristLocation = "left"
        case .right:
            wristLocation = "right"
        default:
            wristLocation = "notSet"
        }
        
        switch device.crownOrientation {
        case .left:
            crownOrientation = "left"
        case .right:
            crownOrientation = "right"
        default:
            crownOrientation = "notSet"
        }
        
        if crownOrientation == "right" {
            allowPrediction = true
        }
        else {
            allowPrediction = false
        }
        deviceName = device.name
        if let version = HKDevice.local().hardwareVersion {
            deviceHardwarwVersion = version
        }

    }
    
    func initSession(mode: AppMode) {
        appMode = mode
        numberLabeledActions = 0
        summaryCount = ["Nothing":0,
                            "Eye rubbing":0,
                            "Eye touching":0,
                            "Glasses readjusting":0,
                            "Eating":0,
                            "Make up":0,
                            "Hair combing":0,
                            "Skin scratching":0,
                            "Teeth brushing":0]
    }
    
    func startUpdates() {
        running = true
        guard motionManager.isAccelerometerAvailable && motionManager.isDeviceMotionAvailable else { return }
        motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateFrequency)
        motionManager.deviceMotionUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateFrequency)
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (accelerometerData, error) in
            if let accelerometerData = accelerometerData {
                // Add the current data sample to the data array
                self.addAccelSampleToDataArray(accelData: accelerometerData)
            }
        }
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: OperationQueue.current!){ (motionData, error) in
            if let motionData = motionData {
                // Add the current data sample to the data array
                self.addMotionSampleToDataArray(motionData: motionData)
            }
        }
    }
    
    func stopUpdates() {
        running = false
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func resetWindow() {
        currentIndexInPredictionWindow = 0
    }
    
    func slideWindow() {
        pause()
        for i in 0..<(ModelConstants.windowSize - ModelConstants.stepSize) {
            for j in 0...18 {
                sensorDataArray[[i, j] as [NSNumber]] = sensorDataArray[[i + ModelConstants.stepSize, j] as [NSNumber]]
            }
        }
        currentIndexInPredictionWindow -= ModelConstants.stepSize
        resume()
    }
    
    func addAccelSampleToDataArray(accelData: CMAccelerometerData){
        sensorDataArray[[currentIndexInPredictionWindow, 0] as [NSNumber]] = accelData.acceleration.x as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 1] as [NSNumber]] = accelData.acceleration.y as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 2] as [NSNumber]] = accelData.acceleration.z as NSNumber
    }
    
    func addMotionSampleToDataArray(motionData: CMDeviceMotion){
        sensorDataArray[[currentIndexInPredictionWindow, 3] as [NSNumber]] = motionData.attitude.yaw as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 4] as [NSNumber]] = motionData.attitude.roll as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 5] as [NSNumber]] = motionData.attitude.pitch as NSNumber
        
        sensorDataArray[[currentIndexInPredictionWindow, 6] as [NSNumber]] = motionData.rotationRate.x as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 7] as [NSNumber]] = motionData.rotationRate.y as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 8] as [NSNumber]] = motionData.rotationRate.z as NSNumber
        
        sensorDataArray[[currentIndexInPredictionWindow, 9] as [NSNumber]] = motionData.userAcceleration.x as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 10] as [NSNumber]] = motionData.userAcceleration.y as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 11] as [NSNumber]] = motionData.userAcceleration.z as NSNumber
        
        sensorDataArray[[currentIndexInPredictionWindow, 12] as [NSNumber]] = motionData.attitude.quaternion.x as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 13] as [NSNumber]] = motionData.attitude.quaternion.y as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 14] as [NSNumber]] = motionData.attitude.quaternion.z as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 15] as [NSNumber]] = motionData.attitude.quaternion.w as NSNumber
        
        sensorDataArray[[currentIndexInPredictionWindow, 16] as [NSNumber]] = motionData.gravity.x as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 17] as [NSNumber]] = motionData.gravity.y as NSNumber
        sensorDataArray[[currentIndexInPredictionWindow, 18] as [NSNumber]] = motionData.gravity.z as NSNumber
        
        // Update the index in the prediction window data array
        currentIndexInPredictionWindow += 1

        // If the data array is full, stop records or make prediction depending on mode
        switch appMode {
        case .manualLabeling:
            if (currentIndexInPredictionWindow == ModelConstants.windowSize) {
                isDataArrayFull = true
                reset()
            }
            
        case .semiAutomaticLabeling:
            if (currentIndexInPredictionWindow == ModelConstants.windowSize) {
                predictedLabel = predictionManager.performModelPrediction(data: sensorDataArray, wristLocation: device.wristLocation)
                if (predictedLabel != "Nothing") && (predictedLabel != "N/A") {
                    reset()
                }
                else {
                    slideWindow()
                }
            }
        
        case .monitoring:
            if (currentIndexInPredictionWindow == ModelConstants.windowSize) {
                predictedLabel = predictionManager.performModelPrediction(data: sensorDataArray, wristLocation: device.wristLocation)
                
                if (monitoredLabel == "All" && predictedLabel != "Nothing") {
                    addToSessionData(label: predictedLabel)
                    numberMonitoredActions += 1
                    resetWindow()
                }
                else if (predictedLabel == monitoredLabel) {
                    addToSessionData(label: predictedLabel)
                    numberMonitoredActions += 1
                    resetWindow()
                }
                else {
                    slideWindow()
                }
            }
        
        case .notSet:
            break
        }
    }
    
    func addToSessionData(label: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: Date())
        
        let sample = MonitoredSample(label:label, date: date)
        monitoredSamples.append(sample)
        sendMonitoredActionToIphone(sample: sample)
    }
    
    func convertToArrays(from mlMultiArray: MLMultiArray) -> [String: [Float]] {
        var accelerometerAccelerationX = [Float]()
        var accelerometerAccelerationY = [Float]()
        var accelerometerAccelerationZ = [Float]()
        var motionYaw = [Float]()
        var motionRoll = [Float]()
        var motionPitch = [Float]()
        var motionRotationRateX = [Float]()
        var motionRotationRateY = [Float]()
        var motionRotationRateZ = [Float]()
        var motionUserAccelerationX = [Float]()
        var motionUserAccelerationY = [Float]()
        var motionUserAccelerationZ = [Float]()
        var motionQuaternionX = [Float]()
        var motionQuaternionY = [Float]()
        var motionQuaternionZ = [Float]()
        var motionQuaternionW = [Float]()
        var motionGravityX = [Float]()
        var motionGravityY = [Float]()
        var motionGravityZ = [Float]()
        
        for t in 0..<ModelConstants.windowSize {
            accelerometerAccelerationX.append(Float(truncating: mlMultiArray[[t, 0] as [NSNumber]]))
            accelerometerAccelerationY.append(Float(truncating: mlMultiArray[[t, 1] as [NSNumber]]))
            accelerometerAccelerationZ.append(Float(truncating: mlMultiArray[[t, 2] as [NSNumber]]))
            motionYaw.append(Float(truncating: mlMultiArray[[t, 3] as [NSNumber]]))
            motionRoll.append(Float(truncating: mlMultiArray[[t, 4] as [NSNumber]]))
            motionPitch.append(Float(truncating: mlMultiArray[[t, 5] as [NSNumber]]))
            motionRotationRateX.append(Float(truncating: mlMultiArray[[t, 6] as [NSNumber]]))
            motionRotationRateY.append(Float(truncating: mlMultiArray[[t, 7] as [NSNumber]]))
            motionRotationRateZ.append(Float(truncating: mlMultiArray[[t, 8] as [NSNumber]]))
            motionUserAccelerationX.append(Float(truncating: mlMultiArray[[t, 9] as [NSNumber]]))
            motionUserAccelerationY.append(Float(truncating: mlMultiArray[[t, 10] as [NSNumber]]))
            motionUserAccelerationZ.append(Float(truncating: mlMultiArray[[t, 11] as [NSNumber]]))
            motionQuaternionX.append(Float(truncating: mlMultiArray[[t, 12] as [NSNumber]]))
            motionQuaternionY.append(Float(truncating: mlMultiArray[[t, 13] as [NSNumber]]))
            motionQuaternionZ.append(Float(truncating: mlMultiArray[[t, 14] as [NSNumber]]))
            motionQuaternionW.append(Float(truncating: mlMultiArray[[t, 15] as [NSNumber]]))
            motionGravityX.append(Float(truncating: mlMultiArray[[t, 16] as [NSNumber]]))
            motionGravityY.append(Float(truncating: mlMultiArray[[t, 17] as [NSNumber]]))
            motionGravityZ.append(Float(truncating: mlMultiArray[[t, 18] as [NSNumber]]))
        }
        
        let arrays = [
            "accelerometerAccelerationX": accelerometerAccelerationX,
            "accelerometerAccelerationY": accelerometerAccelerationY,
            "accelerometerAccelerationZ": accelerometerAccelerationZ,
            "motionYaw": motionYaw,
            "motionRoll": motionRoll,
            "motionPitch": motionPitch,
            "motionRotationRateX": motionRotationRateX,
            "motionRotationRateY": motionRotationRateY,
            "motionRotationRateZ": motionRotationRateZ,
            "motionUserAccelerationX": motionUserAccelerationX,
            "motionUserAccelerationY": motionUserAccelerationY,
            "motionUserAccelerationZ": motionUserAccelerationZ,
            "motionQuaternionX": motionQuaternionX,
            "motionQuaternionY": motionQuaternionY,
            "motionQuaternionZ": motionQuaternionZ,
            "motionQuaternionW": motionQuaternionW,
            "motionGravityX": motionGravityX,
            "motionGravityY": motionGravityY,
            "motionGravityZ": motionGravityZ
        ]
        
        return arrays
        
    }
    
    func sendLabeledActionToIphone(label: String) {
        let dataType = "labeledAction"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: Date())
        
        let sensorDataArrays = convertToArrays(from: sensorDataArray)
        let message: [String: Any] = ["dataType": dataType,
                                      "date": date,
                                      "wristLocation": wristLocation,
                                      "crownOrientation": crownOrientation,
                                      "label": label,
                                      "labelingMode": (appMode == .manualLabeling ? "manual" : "semiAutomatic"),
                                      "sensorDataArrays": sensorDataArrays
        ]
        WatchConnectivityManager.shared.send(message:message)
        numberLabeledActions += 1
        summaryCount[label]! += 1
    }
    
    func sendMonitoredActionToIphone(sample: MonitoredSample) {
        let dataType = "monitoredAction"
        let message: [String: Any] = ["dataType": dataType,
                                      "date": sample.date,
                                      "wristLocation": wristLocation,
                                      "crownOrientation": crownOrientation,
                                      "label": sample.label]
        WatchConnectivityManager.shared.send(message:message)
        numberMonitoredActions += 1
    }
    
    // MARK: - State Control

    var running: Bool = false

    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    func pause() {
        stopUpdates()
    }

    func resume() {
        startUpdates()
    }
    
    func reset() {
        pause()
        resetWindow()
        isDataArrayFull = false
        predictedLabel = "N/A"
    }

}
