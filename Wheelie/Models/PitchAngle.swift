//
//  PitchAngle.swift
//  Wheelie
//
//  Device pitch angle measurement with timestamp
//

import Foundation

/// Repräsentiert eine Pitch-Winkel-Messung mit Zeitstempel
struct PitchAngle: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let angle: Double  // in Degrees
    
    init(id: UUID = UUID(), timestamp: Date = Date(), angle: Double) {
        self.id = id
        self.timestamp = timestamp
        self.angle = angle
    }
}
