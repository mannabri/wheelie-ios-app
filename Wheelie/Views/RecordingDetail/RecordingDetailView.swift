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
                RouteMapView(
                    coordinates: viewModel.routeCoordinates,
                    region: $viewModel.mapRegion
                )
                .frame(height: 350)
                
                StatisticsGridView(statistics: viewModel.statistics)
                    .padding()
                
                RecordingInfoView(recording: viewModel.recording)
                    .padding(.horizontal)

                if !viewModel.recording.bikePitchAngles.isEmpty {
                    PitchAnglesListView(pitchAngles: viewModel.recording.bikePitchAngles)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .frame(height: 100)
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
            bikePitchAngles: [
                PitchAngle(timestamp: Date().addingTimeInterval(-2), angle: 10),
                PitchAngle(timestamp: Date().addingTimeInterval(-1), angle: 15),
                PitchAngle(timestamp: Date(), angle: 5)
            ]
        ))
    }
}
