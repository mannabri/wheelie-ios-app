//
//  WheeliesChartView.swift
//  Wheelie
//
//  Chart displaying wheelies as horizontal bars showing duration over time
//

import SwiftUI
import Charts

/// View displaying wheelies as a horizontal bar chart
/// Shows wheelie start time on x-axis and duration in seconds on y-axis
struct WheeliesChartView: View {
    let wheelies: [Wheelie]
    
    // Format wheelie start time for display
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private var bestWheelieID: UUID? {
        wheelies.max(by: { $0.duration < $1.duration })?.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wheelies")
                .font(.headline)
            
            Chart {
                ForEach(wheelies, id: \.id) { wheelie in
                    let isBest = wheelie.id == bestWheelieID
                    BarMark(
                        x: .value("Time", wheelie.startDate),
                        y: .value("Duration (s)", Int(wheelie.duration))
                    )
                    .foregroundStyle(isBest ? Color.yellow : Color.blue)
                    .opacity(isBest ? 1.0 : 0.8)
                    .annotation(position: .top) {
                        if isBest {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(Color.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)s")
                        }
                    }
                }
            }
            
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    WheeliesChartView(wheelies: [
        Wheelie(startDate: Date().addingTimeInterval(-3500), endDate: Date().addingTimeInterval(-3495)),
        Wheelie(startDate: Date().addingTimeInterval(-3400), endDate: Date().addingTimeInterval(-3390)),
        Wheelie(startDate: Date().addingTimeInterval(-3200), endDate: Date().addingTimeInterval(-3185)),
        Wheelie(startDate: Date().addingTimeInterval(-2800), endDate: Date().addingTimeInterval(-2790))
    ])
    .padding()
}
