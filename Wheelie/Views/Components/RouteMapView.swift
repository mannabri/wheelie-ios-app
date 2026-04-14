//
//  RouteMapView.swift
//  Wheelie
//
//  Karten-Komponente für die Detailansicht mit Route
//

import SwiftUI
import MapKit

/// Karte für die Detailansicht mit kompletter Route
struct RouteMapView: View {
    
    /// Full route coordinates (with timestamps via the Coordinate model)
    let coordinates: [Coordinate]
    @Binding var region: MKCoordinateRegion
    /// Wheelies to highlight on the map (optional)
    var wheelies: [Wheelie] = []

    // MARK: - Computed Properties

    private var routeCoordinate2Ds: [CLLocationCoordinate2D] {
        coordinates.map { $0.coordinate2D }
    }

    /// Groups consecutive coordinates that fall within any wheelie time range
    /// into segments, each returned as an array of CLLocationCoordinate2D.
    private var wheelieSections: [[CLLocationCoordinate2D]] {
        guard !wheelies.isEmpty, coordinates.count > 1 else { return [] }

        var sections: [[CLLocationCoordinate2D]] = []
        var current: [CLLocationCoordinate2D] = []

        for coord in coordinates {
            let inWheelieSegment = wheelies.contains { wheelie in
                guard let end = wheelie.endDate else { return false }
                return coord.timestamp >= wheelie.startDate && coord.timestamp <= end
            }

            if inWheelieSegment {
                current.append(coord.coordinate2D)
            } else {
                if current.count > 1 {
                    sections.append(current)
                }
                // Keep last point so the next segment connects seamlessly
                current = current.isEmpty ? [] : [current.last!]
                if !inWheelieSegment { current = [] }
            }
        }
        if current.count > 1 { sections.append(current) }

        return sections
    }

    var body: some View {
        Map(initialPosition: .region(region)) {
            // Route als Polyline
            if routeCoordinate2Ds.count > 1 {
                MapPolyline(coordinates: routeCoordinate2Ds)
                    .stroke(.blue, lineWidth: 4)
            }

            // Wheelie-Abschnitte in Orange hervorheben
            ForEach(wheelieSections.indices, id: \.self) { index in
                MapPolyline(coordinates: wheelieSections[index])
                    .stroke(.orange, lineWidth: 6)
            }

            // Startpunkt
            if let first = routeCoordinate2Ds.first {
                Annotation("Start", coordinate: first) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
            
            // Endpunkt
            if let last = routeCoordinate2Ds.last, routeCoordinate2Ds.count > 1 {
                Annotation("Ende", coordinate: last) {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }
}

#Preview {
    let now = Date()
    let coords: [Coordinate] = [
        Coordinate(latitude: 52.520, longitude: 13.405, timestamp: now.addingTimeInterval(-10)),
        Coordinate(latitude: 52.521, longitude: 13.406, timestamp: now.addingTimeInterval(-8)),
        Coordinate(latitude: 52.522, longitude: 13.407, timestamp: now.addingTimeInterval(-6)),
        Coordinate(latitude: 52.523, longitude: 13.408, timestamp: now.addingTimeInterval(-4)),
        Coordinate(latitude: 52.524, longitude: 13.409, timestamp: now.addingTimeInterval(-2)),
    ]
    let wheelies = [
        Wheelie(startDate: now.addingTimeInterval(-8), endDate: now.addingTimeInterval(-4))
    ]
    RouteMapView(
        coordinates: coords,
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.522, longitude: 13.407),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )),
        wheelies: wheelies
    )
}
