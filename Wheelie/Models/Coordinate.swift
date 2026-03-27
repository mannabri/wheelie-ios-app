//
//  Coordinate.swift
//  Wheelie
//
//  Coordinate Model - Repräsentiert einen GPS-Koordinatenpunkt
//

import Foundation
import CoreLocation

/// Repräsentiert einen einzelnen GPS-Koordinatenpunkt
struct Coordinate: Identifiable, Codable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let timestamp: Date
    let accuracy: Double
    
    init(id: UUID = UUID(), latitude: Double, longitude: Double, altitude: Double = 0, timestamp: Date = Date(), accuracy: Double = 0) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
        self.accuracy = accuracy
    }
    
    /// Erstellt eine Coordinate aus einer CLLocation
    init(from location: CLLocation) {
        self.id = UUID()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
        self.accuracy = location.horizontalAccuracy
    }
    
    /// Konvertiert zurück zu CLLocation für Berechnungen
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    /// Konvertiert zu CLLocationCoordinate2D für MapKit
    var coordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
