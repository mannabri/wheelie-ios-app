//
//  RecordingWheelieStatsView.swift
//  Wheelie
//
//  Created by Manuel on 31.03.26.
//

import SwiftUI

struct RecordingWheelieStatsView: View {
    let devicePitchAngle: Double
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.6)
                .ignoresSafeArea()
            VStack {
                Text(String(format: "%.1f°", devicePitchAngle))
            }
        }
        .frame(height: 100)
        .clipShape(.rect(cornerRadius: 24))
        .padding(.horizontal, 8)
    }
}

#Preview {
    RecordingWheelieStatsView(devicePitchAngle: 13.7)
}
