//
//  RecordingStatsView.swift
//  Wheelie
//
//  Live-Statistiken während der Aufnahme
//

import SwiftUI

/// Zeigt Live-Statistiken während der Aufnahme
struct RecordingStatsView: View {
    
    let recording: Recording
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(title: "Dauer", value: recording.formattedDuration, icon: "clock")
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

/// Einzelne Statistik-Anzeige
private struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .monospacedDigit()
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    RecordingStatsView(
        recording: Recording(
            startDate: Date().addingTimeInterval(-3600),
            coordinates: []
        ),
    )
}
