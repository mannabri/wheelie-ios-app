//
//  RecordingsListView.swift
//  Wheelie
//
//  Übersichtsliste aller gespeicherten Aufnahmen
//

import SwiftUI

/// Übersichtsliste aller Aufnahmen
struct RecordingsListView: View {
    
    @StateObject private var viewModel = RecordingsListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Laden...")
                } else if viewModel.recordings.isEmpty {
                    ContentUnavailableView(
                        "Keine Aufnahmen",
                        systemImage: "mappin.slash",
                        description: Text("Starte deine erste GPS-Aufnahme im Aufnahme-Tab.")
                    )
                } else {
                    List {
                        ForEach(viewModel.recordings) { recording in
                            NavigationLink(destination: RecordingDetailView(recording: recording)) {
                                RecordingRowView(recording: recording)
                            }
                        }
                        .onDelete(perform: viewModel.deleteRecordings)
                    }
                }
            }
            .navigationTitle("Aufnahmen")
            .toolbar {
                EditButton()
            }
            .onAppear {
                viewModel.loadRecordings()
            }
            .refreshable {
                viewModel.loadRecordings()
            }
        }
    }
}

#Preview {
    RecordingsListView()
}
