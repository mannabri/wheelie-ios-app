//
//  RecordingsListView.swift
//  Wheelie
//
//  Übersichtsliste aller gespeicherten Aufnahmen
//

import SwiftUI

/// Übersichtsliste aller Aufnahmen
struct AllRecordingsView: View {
    @StateObject private var viewModel = RecordingsListViewModel()

    var body: some View {
        RecordingsListView(isLoading: viewModel.isLoading, recordings: viewModel.recordings, onDelete: viewModel.deleteRecordings)
            .onAppear {
                viewModel.loadRecordings()
            }
            .refreshable {
                viewModel.loadRecordings()
            }
            .navigationTitle("Alle Aufnahmen")
            .toolbar {
                EditButton()
            }
    }
}

#Preview {
    return NavigationStack {
        AllRecordingsView()
    }
}
