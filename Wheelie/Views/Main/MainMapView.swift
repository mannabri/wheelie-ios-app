//
//  MainMapView.swift
//  Wheelie
//
//  Apple Maps style main view with full-size map and bottom sheet
//

import MapKit
import SwiftUI

/// Main view with full-size map and bottom sheet (Apple Maps style)
struct MainMapView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @StateObject private var recordingsListViewModel = RecordingsListViewModel()

    @State private var sheetDetent: PresentationDetent = .medium
    @State private var showRecordingDetail: Bool = false
    @State private var completedRecording: Recording?

    // Sheet detents configuration
    private let smallDetent: PresentationDetent = .height(180)
    private let mediumDetent: PresentationDetent = .medium
    private let largeDetent: PresentationDetent = .large

    var body: some View {
        MapView(
            coordinates: viewModel.currentRecording?.coordinates ?? [],
            currentLocation: viewModel.currentLocation,
            isRecording: viewModel.isRecording,
            wheelies: viewModel.allWheeliesIncludingOngoing
        )
        .overlay(alignment: .top) {
            if viewModel.isRecording, let recording = viewModel.currentRecording {
                RecordingWheelieStatsView(bikePitchAngle: recording.bikePitchAngle, isWheelie: viewModel.isWheelie, wheelieDuration: viewModel.currentWheelieDuration)
            }
        }
        .sheet(isPresented: .constant(true)) {
            SheetContentView(
                viewModel: viewModel,
                recordingsListViewModel: recordingsListViewModel,
                sheetDetent: $sheetDetent,
                completedRecording: $completedRecording,
                showRecordingDetail: $showRecordingDetail
            )
            .presentationDetents(
                viewModel.isRecording
                    ? [smallDetent, mediumDetent]
                    : [mediumDetent, largeDetent],
                selection: $sheetDetent
            )
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: viewModel.isRecording ? smallDetent : mediumDetent))
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showRecordingDetail) {
            if let recording = completedRecording {
                NavigationStack {
                    RecordingDetailView(recording: recording)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Fertig") {
                                    showRecordingDetail = false
                                    completedRecording = nil
                                    recordingsListViewModel.loadRecordings()
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            viewModel.requestLocationPermission()
            viewModel.requestMotionPermission()
            recordingsListViewModel.loadRecordings()

            viewModel.setOnRecordingFinished { recording in
                completedRecording = recording
                showRecordingDetail = true
                sheetDetent = mediumDetent
            }
        }
        .onChange(of: viewModel.isRecording) { _, isRecording in
            // Adjust sheet detent when recording state changes
            if isRecording {
                sheetDetent = smallDetent
            } else {
                sheetDetent = mediumDetent
            }
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

#Preview {
    MainMapView()
}
