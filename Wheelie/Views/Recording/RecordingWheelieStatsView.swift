//
//  RecordingWheelieStatsView.swift
//  Wheelie
//
//  Created by Manuel on 31.03.26.
//

import SwiftUI

struct RecordingWheelieStatsView: View {
    let bikePitchAngle: Double
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.95)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f°", bikePitchAngle))
                            .font(.largeTitle)
                            .fontWeight(.semibold)
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
    ZStack {
        Color(.systemGray5).ignoresSafeArea()
        RecordingWheelieStatsView(bikePitchAngle: 5.2)
    }
}
