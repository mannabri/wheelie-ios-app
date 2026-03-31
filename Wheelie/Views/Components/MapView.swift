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
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
            // Route als Polyline
            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates.map { $0.coordinate2D })
                    .stroke(.blue, lineWidth: 4)
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
    }
}

#Preview {
    MapView(
        coordinates: [],
        currentLocation: nil,
    )
}
