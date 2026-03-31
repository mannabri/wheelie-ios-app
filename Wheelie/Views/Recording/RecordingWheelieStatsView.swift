//
//  RecordingWheelieStatsView.swift
//  Wheelie
//
//  Created by Manuel on 31.03.26.
//

import SwiftUI

struct RecordingWheelieStatsView: View {
    let devicePitchAngle: Double
    let bikePitchAngle: Double
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Gerät")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f°", devicePitchAngle))
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    Divider()
                    VStack(spacing: 4) {
                        Text("Bike")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f°", bikePitchAngle))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 100)
        .clipShape(.rect(cornerRadius: 24))
        .padding(.horizontal, 8)
    }
}

#Preview {
    RecordingWheelieStatsView(devicePitchAngle: 13.7, bikePitchAngle: 5.2)
}
