//
//  SpeechSynthesizer.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 27.10.2023.
//

import Foundation
import AVFoundation

class SpeechSynthesizer: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    
    func speakMessage(message: String) {
        let speechUtterance = AVSpeechUtterance(string: message)
        speechUtterance.rate = 0.5
        speechUtterance.volume = 1
        
        let samanthaVoiceID = "com.apple.voice.compact.en-US.Samantha"
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()

        if availableVoices.first(where: { $0.identifier == samanthaVoiceID }) != nil {
            let samanthaVoice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha")
            speechUtterance.voice = samanthaVoice
        }
        
        synthesizer.speak(speechUtterance)
    }
    
}
