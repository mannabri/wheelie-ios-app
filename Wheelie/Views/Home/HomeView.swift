//
//  HomeView.swift
//  Wheelie
//
//  Created by Manuel on 27.04.26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = RecordingsListViewModel()

    var body: some View {
        List {
            Section(header: Text("Statistik")) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTileView(title: "Bester Wheelie", value: formatDuration(viewModel.bestWheelieDuration))
                    StatTileView(title: "Ø Wheelie", value: formatDuration(viewModel.averageWheelieDuration))
                    StatTileView(title: "Anzahl Wheelies", value: "\(viewModel.totalWheelieCount)")
                    StatTileView(title: "Zeit im Wheelie", value: formatDuration(viewModel.totalWheelieTime))
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section(header: Text("Aufnahmen")) {
                if viewModel.isLoading {
                    ProgressView("Laden...")
                } else if viewModel.recordings.isEmpty {
                    ContentUnavailableView(
                        "Keine Aufnahmen",
                        systemImage: "mappin.slash",
                        description: Text("Starte deine erste GPS-Aufnahme im Aufnahme-Tab.")
                    )
                } else {
                    ForEach(viewModel.recordings.prefix(3)) { recording in
                        NavigationLink(destination: RecordingDetailView(recording: recording)) {
                            RecordingRowView(recording: recording)
                        }
                    }
                    NavigationLink("Alle anzeigen") {
                        AllRecordingsView()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Übersicht")
        .onAppear {
            viewModel.loadRecordings()
        }
        .refreshable {
            viewModel.loadRecordings()
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return String(format: "%02d:%02d min", minutes, seconds)
        } else {
            return String(format: "%d s", seconds)
        }
    }
}

// MARK: - Stat Tile

private struct StatTileView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    return NavigationStack {
        HomeView()
    }
}
