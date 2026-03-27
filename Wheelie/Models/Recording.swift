//
//  Recording.swift
//  Wheelie
//
//  GPS Recording Model - Repräsentiert eine einzelne GPS-Aufnahme
//

import Foundation
import CoreLocation

/// Repräsentiert eine GPS-Aufnahme mit allen zugehörigen Daten
struct Recording: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var coordinates: [Coordinate]
    var pitchAngles: [PitchAngle]
    var status: RecordingStatus
    
    init(id: UUID = UUID(), name: String = "", startDate: Date = Date(), endDate: Date? = nil, coordinates: [Coordinate] = [], pitchAngles: [PitchAngle] = [], status: RecordingStatus = .recording) {
        self.id = id
        self.name = name.isEmpty ? "Aufnahme \(Self.dateFormatter.string(from: startDate))" : name
        self.startDate = startDate
        self.endDate = endDate
        self.coordinates = coordinates
        self.pitchAngles = pitchAngles
        self.status = status
    }
    
    // MARK: - Computed Properties
    
    /// Gesamtdauer der Aufnahme in Sekunden
    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }
    
    /// Formatierte Dauer als String (HH:MM:SS)
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// Gesamtdistanz in Metern
    var totalDistance: Double {
        guard coordinates.count > 1 else { return 0 }
        
        var distance: Double = 0
        for i in 1..<coordinates.count {
            let prev = coordinates[i-1].clLocation
            let curr = coordinates[i].clLocation
            distance += curr.distance(from: prev)
        }
        return distance
    }
    
    /// Formatierte Distanz als String
    var formattedDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.2f km", totalDistance / 1000)
        } else {
            return String(format: "%.0f m", totalDistance)
        }
    }
    
    /// Durchschnittsgeschwindigkeit in km/h
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return (totalDistance / 1000) / (duration / 3600)
    }
    
    /// Formatierte Durchschnittsgeschwindigkeit
    var formattedAverageSpeed: String {
        return String(format: "%.1f km/h", averageSpeed)
    }
    
    // MARK: - Private
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()
}

// MARK: - RecordingStatus

enum RecordingStatus: String, Codable {
    case recording = "recording"
    case paused = "paused"
    case stopped = "stopped"
}
