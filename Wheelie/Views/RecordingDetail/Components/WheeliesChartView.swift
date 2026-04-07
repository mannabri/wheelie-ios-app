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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wheelies")
                .font(.headline)
            
            if wheelies.isEmpty {
                Text("No wheelies recorded")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart {
                    ForEach(wheelies, id: \.id) { wheelie in
                        BarMark(
                            x: .value("Time", wheelie.startDate),
                            y: .value("Duration (s)", Int(wheelie.duration))
                        )
                        .foregroundStyle(.blue)
                        .opacity(0.8)
                    }
                }
                .chartXAxisLabel("Start Time")
                .chartYAxisLabel("Duration (seconds)")
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel(format: .dateTime.hour().minute())
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 250)
                .padding(.vertical, 8)
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
