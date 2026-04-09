//
//  PitchAnglesListView.swift
//  Wheelie
//
//  Created by Manuel on 27.03.26.
//

import SwiftUI
import Charts

struct PitchAnglesListView: View {
    let pitchAngles: [PitchAngle]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) {
            Text("Angles")
                .font(.headline)
            Chart {
                ForEach(pitchAngles) { pitch in
                    LineMark(
                        x: .value("Time", pitch.timestamp),
                        y: .value("Angle", pitch.angle)
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisValueLabel(format: .dateTime.hour().minute()) // Format axis labels
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    PitchAnglesListView(pitchAngles: [
        PitchAngle(timestamp: Date().addingTimeInterval(-6), angle: 15),
        PitchAngle(timestamp: Date().addingTimeInterval(-5), angle: 10),
        PitchAngle(timestamp: Date().addingTimeInterval(-4), angle: 10),
        PitchAngle(timestamp: Date().addingTimeInterval(-3), angle: 10),
        PitchAngle(timestamp: Date().addingTimeInterval(-2), angle: 10),
        PitchAngle(timestamp: Date().addingTimeInterval(-1), angle: 15),
        PitchAngle(timestamp: Date(), angle: 5)
    ])
}


