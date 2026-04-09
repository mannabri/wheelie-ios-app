//
//  MapView.swift
//  Wheelie
//
//  Karten-Komponente für Live-Aufnahme
//

import SwiftUI
import MapKit

/// Karte für die Live-Aufnahme
struct MapView: View {
    
    let coordinates: [Coordinate]
    let currentLocation: CLLocation?
    let isRecording: Bool
    var wheelies: [Wheelie] = []

    // MARK: - Computed Properties

    /// Checks whether a coordinate falls within any wheelie time range.
    private func isInWheelieSegment(_ coord: Coordinate) -> Bool {
        wheelies.contains { wheelie in
            guard let end = wheelie.endDate else {
                // Ongoing wheelie – include coordinates from startDate onward
                return coord.timestamp >= wheelie.startDate
            }
            return coord.timestamp >= wheelie.startDate && coord.timestamp <= end
        }
    }

    /// Splits the full route into segments of consecutive normal (non-wheelie) coordinates.
    /// Adjacent segments share an endpoint so polylines connect seamlessly.
    private var normalSections: [[CLLocationCoordinate2D]] {
        guard coordinates.count > 1 else { return [] }
        var sections: [[CLLocationCoordinate2D]] = []
        var current: [CLLocationCoordinate2D] = []

        for coord in coordinates {
            if !isInWheelieSegment(coord) {
                current.append(coord.coordinate2D)
            } else {
                // Add the wheelie-start point so the normal section connects to it
                if !current.isEmpty {
                    current.append(coord.coordinate2D)
                    sections.append(current)
                }
                current = []
            }
        }
        if current.count > 1 { sections.append(current) }
        return sections
    }

    /// Splits the full route into segments of consecutive wheelie coordinates.
    /// Adjacent segments share an endpoint so polylines connect seamlessly.
    private var wheelieSections: [[CLLocationCoordinate2D]] {
        guard !wheelies.isEmpty, coordinates.count > 1 else { return [] }
        var sections: [[CLLocationCoordinate2D]] = []
        var current: [CLLocationCoordinate2D] = []

        for coord in coordinates {
            if isInWheelieSegment(coord) {
                current.append(coord.coordinate2D)
            } else {
                // Add the first-normal point so the wheelie section connects to it
                if !current.isEmpty {
                    current.append(coord.coordinate2D)
                    sections.append(current)
                }
                current = []
            }
        }
        if current.count > 1 { sections.append(current) }
        return sections
    }
    
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
            // Normal sections (blue polylines)
            ForEach(normalSections.indices, id: \.self) { index in
                MapPolyline(coordinates: normalSections[index])
                    .stroke(.blue, lineWidth: 4)
            }
            
            // Wheelie sections (orange polylines)
            ForEach(wheelieSections.indices, id: \.self) { index in
                MapPolyline(coordinates: wheelieSections[index])
                    .stroke(.orange, lineWidth: 6)
            }
            
            // Startpunkt
            if let first = coordinates.first {
                Annotation("Start", coordinate: first.coordinate2D) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 100)
        }
        .onChange(of: isRecording) { _, newValue in // TODO: deprecated -> update
            if newValue {
                position = .userLocation(followsHeading: true, fallback: .automatic)
            }
        }
    }
}

#Preview {
    MapView(
        coordinates: [],
        currentLocation: nil,
        isRecording: false
    )
}
