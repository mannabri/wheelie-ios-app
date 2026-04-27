//
//  RecordingView.swift
//  Wheelie
//
//  Hauptansicht für GPS-Aufnahme mit Karte und Steuerung
//

import MapKit
import SwiftUI

/// Ansicht für die aktive GPS-Aufnahme
struct RecordingView: View {
    @Binding var isRecordingActive: Bool
    let onRecordingFinished: (Recording) -> Void
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            MapView(
                coordinates: viewModel.currentRecording?.coordinates ?? [],
                currentLocation: viewModel.currentLocation,
                isRecording: viewModel.isRecording,
                wheelies: viewModel.allWheeliesIncludingOngoing
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
        .overlay(alignment: .top) {
            if viewModel.isRecording, let recording = viewModel.currentRecording {
                RecordingWheelieStatsView(bikePitchAngle: recording.bikePitchAngle, isWheelie: viewModel.isWheelie, wheelieDuration: viewModel.currentWheelieDuration)
            }
        }
        .overlay(alignment: .bottom) {
            if !viewModel.isRecording {
                Button(action: viewModel.startRecording) {
                    HStack {
                        Image(systemName: "record.circle")
                        Text("Aufnahme starten")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .background(Color.red)
                    .clipShape(Capsule())
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: Binding(get: { viewModel.isRecording }, set: { _ in })) {
            if let recording = viewModel.currentRecording {
                VStack {
                    RecordingStatsCardView(recording: recording)
                    Button(action: viewModel.stopRecording) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Aufnahme beenden")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
//                        .cornerRadius(12)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                }
                .presentationDetents([.height(180)])
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
            }
        }
    }
}

// TODO: move into seperate component
struct RecordingStatsCardView: View {
    let recording: Recording

    var body: some View {
        HStack(spacing: 0) {
            // Duration
            StatColumn(value: recording.formattedDurationShort, label: "Dauer")

            // Distance
            StatColumn(value: recording.formattedDistanceShort, label: "km")

            // Wheelies count
            StatColumn(value: "\(recording.wheelies.count)", label: "Wheelies")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
}

private struct StatColumn: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .monospacedDigit()

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RecordingView(isRecordingActive: .constant(false), onRecordingFinished: { _ in })
}
