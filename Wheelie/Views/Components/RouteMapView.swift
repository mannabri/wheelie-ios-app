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
    
    let coordinates: [CLLocationCoordinate2D]
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        Map(initialPosition: .region(region)) {
            // Route als Polyline
            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates)
                    .stroke(.blue, lineWidth: 4)
            }
            
            // Startpunkt
            if let first = coordinates.first {
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
            if let last = coordinates.last, coordinates.count > 1 {
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
    RouteMapView(
        coordinates: [
            CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405),
            CLLocationCoordinate2D(latitude: 52.521, longitude: 13.406),
            CLLocationCoordinate2D(latitude: 52.522, longitude: 13.407)
        ],
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    )
}
