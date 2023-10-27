//
//  LabeledAction.swift
//  EyeRub
//
//  Created by Tom MERY on 27.06.23.
//

import Foundation
import RealmSwift

class LabeledAction: Object, ObjectKeyIdentifiable, Action {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var timestamp = Date()
    @Persisted var userID: String
    @Persisted var wristLocation: String
    @Persisted var crownOrientation: String
    @Persisted var label: String
    @Persisted var labelingMode: String
    @Persisted var accelerometerAccelerationX: List<Float>
    @Persisted var accelerometerAccelerationY: List<Float>
    @Persisted var accelerometerAccelerationZ: List<Float>
    @Persisted var motionYaw: List<Float>
    @Persisted var motionRoll: List<Float>
    @Persisted var motionPitch: List<Float>
    @Persisted var motionRotationRateX: List<Float>
    @Persisted var motionRotationRateY: List<Float>
    @Persisted var motionRotationRateZ: List<Float>
    @Persisted var motionUserAccelerationX: List<Float>
    @Persisted var motionUserAccelerationY: List<Float>
    @Persisted var motionUserAccelerationZ: List<Float>
    @Persisted var motionQuaternionX: List<Float>
    @Persisted var motionQuaternionY: List<Float>
    @Persisted var motionQuaternionZ: List<Float>
    @Persisted var motionQuaternionW: List<Float>
    @Persisted var motionGravityX: List<Float>
    @Persisted var motionGravityY: List<Float>
    @Persisted var motionGravityZ: List<Float>

    convenience init(userID: String, wristLocation: String, crownOrientation: String, label: String, labelingMode:String, sensorDataArrays: [String: [Float]]) {
        self.init()
        self.userID = userID
        self.wristLocation = wristLocation
        self.crownOrientation = crownOrientation
        self.label = label
        self.labelingMode = labelingMode
        self.accelerometerAccelerationX.append(objectsIn: sensorDataArrays["accelerometerAccelerationX"] ?? [])
        self.accelerometerAccelerationY.append(objectsIn: sensorDataArrays["accelerometerAccelerationY"] ?? [])
        self.accelerometerAccelerationZ.append(objectsIn: sensorDataArrays["accelerometerAccelerationZ"] ?? [])
        self.motionYaw.append(objectsIn: sensorDataArrays["motionYaw"] ?? [])
        self.motionRoll.append(objectsIn: sensorDataArrays["motionRoll"] ?? [])
        self.motionPitch.append(objectsIn: sensorDataArrays["motionPitch"] ?? [])
        self.motionRotationRateX.append(objectsIn: sensorDataArrays["motionRotationRateX"] ?? [])
        self.motionRotationRateY.append(objectsIn: sensorDataArrays["motionRotationRateY"] ?? [])
        self.motionRotationRateZ.append(objectsIn: sensorDataArrays["motionRotationRateZ"] ?? [])
        self.motionUserAccelerationX.append(objectsIn: sensorDataArrays["motionUserAccelerationX"] ?? [])
        self.motionUserAccelerationY.append(objectsIn: sensorDataArrays["motionUserAccelerationY"] ?? [])
        self.motionUserAccelerationZ.append(objectsIn: sensorDataArrays["motionUserAccelerationZ"] ?? [])
        self.motionQuaternionX.append(objectsIn: sensorDataArrays["motionQuaternionX"] ?? [])
        self.motionQuaternionY.append(objectsIn: sensorDataArrays["motionQuaternionY"] ?? [])
        self.motionQuaternionZ.append(objectsIn: sensorDataArrays["motionQuaternionZ"] ?? [])
        self.motionQuaternionW.append(objectsIn: sensorDataArrays["motionQuaternionW"] ?? [])
        self.motionGravityX.append(objectsIn: sensorDataArrays["motionGravityX"] ?? [])
        self.motionGravityY.append(objectsIn: sensorDataArrays["motionGravityY"] ?? [])
        self.motionGravityZ.append(objectsIn: sensorDataArrays["motionGravityZ"] ?? [])
    }
    
}
