//
//  PredictionManager.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 09.12.22.
//

import Foundation
import CoreML
import WatchKit

class PredictionManager {
    let activityClassifierLeft: TransformerClassifierLeft = {
        do {
            let config = MLModelConfiguration()
            return try TransformerClassifierLeft(configuration: config)
        } catch {
            fatalError("Couldn't create activityClassifier")
        }
    }()
    
    let activityClassifierRight: TransformerClassifierRight = {
        do {
            let config = MLModelConfiguration()
            return try TransformerClassifierRight(configuration: config)
        } catch {
            fatalError("Couldn't create activityClassifier")
        }
    }()
        
    func performModelPrediction(data: MLMultiArray, wristLocation: WKInterfaceDeviceWristLocation, threshold: Float) -> String {
        var predictedLabel: String
        var classProba: MLMultiArray
        var label: Int
        
        switch wristLocation {
        case .left:
            let prediction = try! activityClassifierLeft.prediction(input:data)
            classProba = prediction.output
        case .right:
            let prediction = try! activityClassifierRight.prediction(input:data)
            classProba = prediction.output
        }
        
        if let (maxIndex, maxValue) = getMaxIndexAndValue(classProba) {
            if maxValue > threshold {
                label = maxIndex
                print(maxValue)
            } else {
                label = 4
            }
        } else {
            label = 5
        }
        
        switch label {
        case 0:
            predictedLabel = "Face touching"
        case 1:
            predictedLabel = "Eye rubbing"
        case 2:
            predictedLabel = "Hair combing/Skin scratching"
        case 3:
            predictedLabel = "Teeth brushing"
        case 4:
            predictedLabel = "Nothing"
        default:
            predictedLabel = "N/A"
        }
        print(predictedLabel)
        return predictedLabel
    }

    func getMaxIndexAndValue(_ multiArray: MLMultiArray) -> (Int, Float)? {
        guard let pointer = try? UnsafeBufferPointer<Float>(multiArray) else {
            return nil
        }
        
        let array = Array(pointer)
        var maxIndex = 0
        var maxValue = array[0]

        for i in 1..<multiArray.count {
            if array[i] > maxValue {
                maxIndex = i
                maxValue = array[i]
            }
        }

        return (maxIndex, maxValue)
    }
}
