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
    
    // MARK: - Statistics
    
    /// Best (longest) wheelie duration across all recordings
    var bestWheelieDuration: TimeInterval {
        recordings.flatMap { $0.wheelies }.map { $0.duration }.max() ?? 0
    }
    
    /// Average wheelie duration across all recordings
    var averageWheelieDuration: TimeInterval {
        let all = recordings.flatMap { $0.wheelies }.map { $0.duration }
        guard !all.isEmpty else { return 0 }
        return all.reduce(0, +) / Double(all.count)
    }
    
    /// Total number of wheelies across all recordings
    var totalWheelieCount: Int {
        recordings.reduce(0) { $0 + $1.wheelies.count }
    }
    
    /// Total time spent in wheelie across all recordings
    var totalWheelieTime: TimeInterval {
        recordings.flatMap { $0.wheelies }.map { $0.duration }.reduce(0, +)
    }
    
    /// Löscht mehrere Aufnahmen
    func deleteRecordings(at offsets: IndexSet) {
        for index in offsets {
            deleteRecording(recordings[index])
        }
    }
}
