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
    var bikePitchAngles: [PitchAngle]
    var devicePitchAngle: Double = 0.0
    var initialDevicePitchAngle: Double?
    var status: RecordingStatus
    
    init(id: UUID = UUID(), name: String = "", startDate: Date = Date(), endDate: Date? = nil, coordinates: [Coordinate] = [], pitchAngles: [PitchAngle] = [], bikePitchAngles: [PitchAngle] = [], status: RecordingStatus = .recording) {
        self.id = id
        self.name = name.isEmpty ? "Aufnahme \(Self.dateFormatter.string(from: startDate))" : name
        self.startDate = startDate
        self.endDate = endDate
        self.coordinates = coordinates
        self.pitchAngles = pitchAngles
        self.bikePitchAngles = bikePitchAngles
        self.status = status
    }
    
    // MARK: - Computed Properties
    
    /// Berechneter Bike-Pitch-Winkel (devicePitchAngle - initialDevicePitchAngle)
    var bikePitchAngle: Double {
        guard let initial = initialDevicePitchAngle else { return 0.0 }
        let angle = devicePitchAngle - initial
        return max(0.0, angle) // Minimum 0°
    }
    
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

// MARK: - Codable Implementation
// TODO: check if this is really necessary
extension Recording {
    enum CodingKeys: String, CodingKey {
        case id, name, startDate, endDate, coordinates, pitchAngles, bikePitchAngles, devicePitchAngle, initialDevicePitchAngle, status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        coordinates = try container.decode([Coordinate].self, forKey: .coordinates)
        pitchAngles = try container.decode([PitchAngle].self, forKey: .pitchAngles)
        bikePitchAngles = try container.decodeIfPresent([PitchAngle].self, forKey: .bikePitchAngles) ?? []
        devicePitchAngle = try container.decodeIfPresent(Double.self, forKey: .devicePitchAngle) ?? 0.0
        initialDevicePitchAngle = try container.decodeIfPresent(Double.self, forKey: .initialDevicePitchAngle)
        status = try container.decode(RecordingStatus.self, forKey: .status)
    }
}
