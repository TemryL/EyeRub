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
    
    func performModelPrediction(data: MLMultiArray, wristLocation: WKInterfaceDeviceWristLocation) -> String {
        var predictedLabel: String
        var label: Int32
        
        switch wristLocation {
        case .left:
            let prediction = try! activityClassifierLeft.prediction(input:data)
            label = Int32(truncating: prediction.output[0])
        case .right:
            let prediction = try! activityClassifierRight.prediction(input:data)
            label = Int32(truncating: prediction.output[0])
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
}
