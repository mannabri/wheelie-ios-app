//
//  StorageManager.swift
//  Wheelie
//
//  Service für persistente Datenspeicherung
//

import Foundation

/// Verwaltet die Speicherung von Aufnahmen
class StorageManager {
    
    // MARK: - Singleton
    
    static let shared = StorageManager()
    
    // MARK: - Private Properties
    
    private let recordingsKey = "recordings"
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var recordingsFileURL: URL {
        documentsDirectory.appendingPathComponent("recordings.json")
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Speichert alle Aufnahmen
    func saveRecordings(_ recordings: [Recording]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(recordings)
        try data.write(to: recordingsFileURL)
    }
    
    /// Lädt alle Aufnahmen
    func loadRecordings() throws -> [Recording] {
        guard fileManager.fileExists(atPath: recordingsFileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: recordingsFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Recording].self, from: data)
    }
    
    /// Speichert eine einzelne Aufnahme (fügt hinzu oder aktualisiert)
    func saveRecording(_ recording: Recording) throws {
        var recordings = try loadRecordings()
        
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
        } else {
            recordings.append(recording)
        }
        
        try saveRecordings(recordings)
    }
    
    /// Löscht eine Aufnahme
    func deleteRecording(_ recording: Recording) throws {
        var recordings = try loadRecordings()
        recordings.removeAll { $0.id == recording.id }
        try saveRecordings(recordings)
    }
    
    /// Löscht alle Aufnahmen
    func deleteAllRecordings() throws {
        try saveRecordings([])
    }
}
