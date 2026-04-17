//
//  SheetContentView.swift
//  Wheelie
//
//  Bottom sheet content that adapts based on recording state
//

import SwiftUI

/// Sheet content that changes based on recording state
struct SheetContentView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @ObservedObject var recordingsListViewModel: RecordingsListViewModel
    @Binding var sheetDetent: PresentationDetent
    @Binding var completedRecording: Recording?
    @Binding var showRecordingDetail: Bool
    
    private let smallDetent: PresentationDetent = .height(180)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isRecording {
                    recordingContent
                } else {
                    idleContent
                }
            }
        }
    }
    
    // MARK: - Recording Content
    
    private var recordingContent: some View {
        VStack(spacing: 16) {
            // Recording stats card (Apple Maps style)
            if let recording = viewModel.currentRecording {
                RecordingStatsCardView(recording: recording)
                    .padding(.horizontal)
            }
            
            // Stop button only visible when sheet is expanded
            if sheetDetent != smallDetent {
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
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    // MARK: - Idle Content
    
    private var idleContent: some View {
        VStack(spacing: 20) {
            // Start recording button
            Button(action: viewModel.startRecording) {
                HStack {
                    Image(systemName: "record.circle")
                    Text("Aufnahme starten")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .clipShape(Capsule())
                .padding(.vertical)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Recent recordings section
            if !recordingsListViewModel.recordings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Letzte Aufnahmen")
                            .font(.headline)
                        
                        Spacer()
                        
                        NavigationLink(destination: RecordingsListView()) {
                            Text("Alle anzeigen")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Show up to 3 recent recordings
                    ForEach(recordingsListViewModel.recordings.prefix(3)) { recording in
                        NavigationLink(destination: RecordingDetailView(recording: recording)) {
                            RecordingRowView(recording: recording)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else if recordingsListViewModel.isLoading {
                ProgressView("Laden...")
                    .padding()
            } else {
                ContentUnavailableView(
                    "Keine Aufnahmen",
                    systemImage: "mappin.slash",
                    description: Text("Starte deine erste GPS-Aufnahme.")
                )
                .padding()
            }
            
            Spacer()
        }
    }
}

/// Apple Maps style stats card for recording
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

/// Individual stat column (Apple Maps style)
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

/// Expanded stats view for the sheet (legacy)
struct RecordingStatsExpandedView: View {
    let recording: Recording
    
    var body: some View {
        VStack(spacing: 16) {
            // Main stats
            HStack(spacing: 30) {
                StatBox(title: "Dauer", value: recording.formattedDuration, icon: "clock.fill")
                StatBox(title: "Distanz", value: recording.formattedDistance, icon: "arrow.left.and.right")
                StatBox(title: "Wheelies", value: "\(recording.wheelies.count)", icon: "bicycle")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

/// Individual stat box
private struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Idle State") {
    SheetContentView(
        viewModel: RecordingViewModel(),
        recordingsListViewModel: RecordingsListViewModel(),
        sheetDetent: .constant(.medium),
        completedRecording: .constant(nil),
        showRecordingDetail: .constant(false)
    )
}
