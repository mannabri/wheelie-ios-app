//
//  RecordingRowView.swift
//  Wheelie
//
//  Einzelne Zeile in der Aufnahmeliste
//

import SwiftUI

/// Einzelne Aufnahme in der Liste
struct RecordingRowView: View {
    
    let recording: Recording
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recording.name)
                .font(.headline)
            
            HStack(spacing: 15) {
                Label(dateFormatter.string(from: recording.startDate), systemImage: "calendar")
                
                Label(recording.formattedDuration, systemImage: "clock")
                
                Label(recording.formattedDistance, systemImage: "arrow.left.and.right")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecordingRowView(recording: Recording(
        name: "Aufnahme 27.04.2026 08:46",
        startDate: Date(),
        coordinates: []
    ))
}
