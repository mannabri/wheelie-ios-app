//
//  RecordingDetailView.swift
//  Wheelie
//
//  Detailansicht einer Aufnahme mit Karte und Statistiken
//

import SwiftUI
import MapKit

/// Detailansicht einer einzelnen Aufnahme
struct RecordingDetailView: View {
    
    @StateObject private var viewModel: RecordingDetailViewModel
    
    init(recording: Recording) {
        _viewModel = StateObject(wrappedValue: RecordingDetailViewModel(recording: recording))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Karte mit Route
                RouteMapView(
                    coordinates: viewModel.routeCoordinates,
                    region: $viewModel.mapRegion
                )
                .frame(height: 350)
                
                // Statistiken
                StatisticsGridView(statistics: viewModel.statistics)
                    .padding()
                
                // Zusätzliche Infos
                RecordingInfoView(recording: viewModel.recording)
                    .padding(.horizontal)
                
                // Pitch Angles Liste
                if !viewModel.recording.pitchAngles.isEmpty {
                    PitchAnglesListView(pitchAngles: viewModel.recording.pitchAngles)
                        .padding(.horizontal)
                        .padding(.top, 16)
                }
            }
        }
        .navigationTitle(viewModel.recording.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Grid mit Statistiken
private struct StatisticsGridView: View {
    let statistics: [(title: String, value: String)]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(statistics, id: \.title) { stat in
                StatisticCard(title: stat.title, value: stat.value)
            }
        }
    }
}

/// Einzelne Statistik-Karte
private struct StatisticCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

/// Zusätzliche Aufnahme-Informationen
private struct RecordingInfoView: View {
    let recording: Recording
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            LabeledContent("Startzeit", value: dateFormatter.string(from: recording.startDate))
            
            if let endDate = recording.endDate {
                LabeledContent("Endzeit", value: dateFormatter.string(from: endDate))
            }
            
            LabeledContent("GPS-Punkte", value: "\(recording.coordinates.count)")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

/// Liste der aufgezeichneten Pitch-Winkel
private struct PitchAnglesListView: View {
    let pitchAngles: [PitchAngle]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pitch-Winkel")
                .font(.headline)
                
            
            List {
                ForEach(pitchAngles) { pitchAngle in
                    Text("123")
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(dateFormatter.string(from: pitchAngle.timestamp))
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//
//                            Text(String(format: "%.1f°", pitchAngle.angle))
//                                .font(.headline)
//                                .monospacedDigit()
//                        }
//
//                        Spacer()
//
//                        // Visual indicator
//                        Image(systemName: "phone.badge.checkmark")
//                            .foregroundColor(.blue)
//                            .font(.caption)
//                    }
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear{
            print("pitchAngles")
            dump(pitchAngles) // TODO: remove dump
        }
    }

}

#Preview {
    NavigationStack {
        RecordingDetailView(recording: Recording(
            name: "Testaufnahme",
            startDate: Date().addingTimeInterval(-3600),
            endDate: Date(),
            coordinates: [
                Coordinate(latitude: 52.52, longitude: 13.405),
                Coordinate(latitude: 52.521, longitude: 13.406),
                Coordinate(latitude: 52.522, longitude: 13.407)
            ],
            pitchAngles: [
                PitchAngle(timestamp: Date().addingTimeInterval(-3000), angle: 10),
                PitchAngle(timestamp: Date().addingTimeInterval(-2000), angle: 15),
                PitchAngle(timestamp: Date().addingTimeInterval(-1000), angle: 5)
            ]
        ))
    }
}
