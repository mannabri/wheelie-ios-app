//
//  RecordingView.swift
//  Wheelie
//
//  Hauptansicht für GPS-Aufnahme mit Karte und Steuerung
//

import SwiftUI
import MapKit

/// Ansicht für die aktive GPS-Aufnahme
struct RecordingView: View {
    @Binding var isRecordingActive: Bool
    let onRecordingFinished: (Recording) -> Void
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Karte
                MapView(
                    coordinates: viewModel.currentRecording?.coordinates ?? [],
                    currentLocation: viewModel.currentLocation,
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Statistiken wahrend der Aufnahme
                if viewModel.isRecording, let recording = viewModel.currentRecording {
                    RecordingStatsView(recording: recording, devicePitchAngle: viewModel.devicePitchAngle)
                }

                // Steuerungsbuttons
                RecordingControlsView(
                    isRecording: viewModel.isRecording,
                    isPaused: viewModel.isPaused,
                    onStart: viewModel.startRecording,
                    onPause: viewModel.pauseRecording,
                    onResume: viewModel.resumeRecording,
                    onStop: viewModel.stopRecording
                )
                .padding()
            }
            .navigationTitle("GPS Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.requestLocationPermission()
                viewModel.requestMotionPermission()
                viewModel.setOnRecordingFinished(onRecordingFinished)
                isRecordingActive = viewModel.isRecording
            }
            .onChange(of: viewModel.isRecording) { _, isRecording in
                isRecordingActive = isRecording
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    RecordingView(isRecordingActive: .constant(false), onRecordingFinished: { _ in })
}
