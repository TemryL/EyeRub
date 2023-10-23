//
//  LabelEncoder.swift
//  EyeRub
//
//  Created by Tom MERY on 16.02.23.
//

import Foundation

class LabelEncoder {
    let labelEncoder: [String:String] = ["Nothing":"NO",
                                        "Eye rubbing":"ER",
                                        "Eye touching":"ET",
                                        "Glasses readjusting":"GR",
                                        "Eating":"EA",
                                        "Make up":"MU",
                                        "Hair combing":"HC",
                                        "Skin scratching":"SC",
                                        "Teeth brushing":"TB"]
    
    let labelDecoder: [String:String] = ["NO":"Nothing",
                                         "ER":"Eye rubbing",
                                         "ET":"Eye touching",
                                         "GR":"Glasses readjusting",
                                         "EA":"Eating",
                                         "MU":"Make up",
                                         "HC":"Hair combing",
                                         "SC":"Skin scratching",
                                         "TB":"Teeth brushing"]
    
    func encode(label: String) -> String? {
        return labelEncoder[label]
    }
    
    func decode(label: String) -> String? {
        return labelDecoder[label]
    }
}
