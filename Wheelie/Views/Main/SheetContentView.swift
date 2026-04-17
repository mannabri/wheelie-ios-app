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
    
    @ViewBuilder
    private var recordingContent: some View {
        VStack(spacing: 16) {
            // Recording stats
            if let recording = viewModel.currentRecording {
                RecordingStatsExpandedView(recording: recording)
                    .padding(.horizontal)
            }
            
            // Stop button only visible when sheet is expanded
            if sheetDetent != smallDetent {
                Divider()
                    .padding(.horizontal)
                
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
    
    @ViewBuilder
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
                .cornerRadius(12)
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

/// Expanded stats view for the sheet
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
