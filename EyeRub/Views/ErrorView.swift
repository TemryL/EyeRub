//
//  ErrorView.swift
//  EyeRub
//
//  Created by Tom MERY on 12.07.23.
//

import SwiftUI

struct ErrorView: View {
    @State var error: Error
        
    var body: some View {
        Text("Error: \(error.localizedDescription)")
    }
}
