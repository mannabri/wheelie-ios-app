//
//  RecordingControlsView.swift
//  Wheelie
//
//  Steuerungsbuttons für GPS-Aufnahme
//

import SwiftUI

/// Steuerungsbuttons für Start, Pause, Stop
struct RecordingControlsView: View {
    
    let isRecording: Bool
    let isPaused: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            if isRecording {
                // Stop Button
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                // Pause/Resume Button
                Button(action: isPaused ? onResume : onPause) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(isPaused ? Color.green : Color.orange)
                        .clipShape(Circle())
                }
            } else {
                // Start Button
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "record.circle")
                        Text("Aufnahme starten")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.red)
                    .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview("Nicht aufnehmen") {
    RecordingControlsView(
        isRecording: false,
        isPaused: false,
        onStart: {},
        onPause: {},
        onResume: {},
        onStop: {}
    )
}

#Preview("Aufnahme läuft") {
    RecordingControlsView(
        isRecording: true,
        isPaused: false,
        onStart: {},
        onPause: {},
        onResume: {},
        onStop: {}
    )
}

#Preview("Pausiert") {
    RecordingControlsView(
        isRecording: true,
        isPaused: true,
        onStart: {},
        onPause: {},
        onResume: {},
        onStop: {}
    )
}
