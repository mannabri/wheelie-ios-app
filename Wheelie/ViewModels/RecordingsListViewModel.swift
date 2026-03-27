//
//  RecordingsListViewModel.swift
//  Wheelie
//
//  ViewModel für die Übersichtsliste aller Aufnahmen
//

import Foundation
import Combine

/// ViewModel für die Aufnahmenübersicht
@MainActor
class RecordingsListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recordings: [Recording] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let storageManager: StorageManager
    
    // MARK: - Initialization
    
    init(storageManager: StorageManager? = nil) {
        self.storageManager = storageManager ?? .shared
    }
    
    // MARK: - Public Methods
    
    /// Lädt alle Aufnahmen
    func loadRecordings() {
        isLoading = true
        
        do {
            recordings = try storageManager.loadRecordings()
                .sorted { $0.startDate > $1.startDate } // Neueste zuerst
        } catch {
            errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
            recordings = []
        }
        
        isLoading = false
    }
    
    /// Löscht eine Aufnahme
    func deleteRecording(_ recording: Recording) {
        do {
            try storageManager.deleteRecording(recording)
            recordings.removeAll { $0.id == recording.id }
        } catch {
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }
    
    /// Löscht mehrere Aufnahmen
    func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            deleteRecording(recordings[index])
        }
    }
}
