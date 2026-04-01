//
//  RecordingDetailViewModel.swift
//  Wheelie
//
//  ViewModel für die Detailansicht einer Aufnahme
//

import Foundation
import MapKit
import Combine

/// ViewModel für die Detailansicht einer Aufnahme
@MainActor
class RecordingDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recording: Recording
    @Published var mapRegion: MKCoordinateRegion
    
    // MARK: - Computed Properties
    
    /// Route als Array von CLLocationCoordinate2D für MapKit
    var routeCoordinates: [CLLocationCoordinate2D] {
        recording.coordinates.map { $0.coordinate2D }
    }
    
    /// Statistiken der Aufnahme
    var statistics: [(title: String, value: String)] {
        [
            ("Dauer", recording.formattedDuration),
            ("Distanz", recording.formattedDistance),
            ("Ø Geschwindigkeit", recording.formattedAverageSpeed),
            ("Punkte", "\(recording.coordinates.count)"),
        ]
    }
    
    // MARK: - Initialization
    
    init(recording: Recording) {
        self.recording = recording
        self.mapRegion = Self.calculateRegion(for: recording.coordinates)
    }
    
    // MARK: - Private Methods
    
    /// Berechnet die optimale Kartenregion für die Koordinaten
    private static func calculateRegion(for coordinates: [Coordinate]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            // Standardregion (Deutschland)
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            )
        }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.3, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.3, 0.01)
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
