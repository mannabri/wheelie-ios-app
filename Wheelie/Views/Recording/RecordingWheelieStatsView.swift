//
//  RecordingWheelieStatsView.swift
//  Wheelie
//
//  Created by Manuel on 31.03.26.
//

import SwiftUI

struct RecordingWheelieStatsView: View {
    let bikePitchAngle: Double
    let isWheelie: Bool
    let wheelieDuration: TimeInterval

    private var formattedDuration: String {
        if !isWheelie {
            return "00:00"
        }

        let minutes = Int(wheelieDuration) / 60
        let seconds = Int(wheelieDuration) % 60
        let milliseconds = Int((wheelieDuration.truncatingRemainder(dividingBy: 1)) * 100)

        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    var body: some View {
        ZStack {
            (isWheelie ? Color.green : Color.white)
                .opacity(0.95)
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    Text(String(format: "%.1f°", bikePitchAngle))
                    Text(formattedDuration)
                }
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
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
        VStack {
            RecordingWheelieStatsView(bikePitchAngle: 5.2, isWheelie: false, wheelieDuration: 0)
            RecordingWheelieStatsView(bikePitchAngle: 20, isWheelie: true, wheelieDuration: 3.52)
        }
    }
}
