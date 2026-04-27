//
//  RecordingListView.swift
//  Wheelie
//
//  Created by Manuel on 27.04.26.
//

import SwiftUI

struct RecordingsListView: View {
    let isLoading: Bool
    var isPreview: Bool = false
    let recordings: [Recording]
    var onDelete: ((IndexSet) -> Void)? = nil

    private var displayedRecordings: [Recording] {
        isPreview ? Array(recordings.prefix(3)) : recordings
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Laden...")
            } else if recordings.isEmpty {
                ContentUnavailableView(
                    "Keine Aufnahmen",
                    systemImage: "mappin.slash",
                    description: Text("Starte deine erste GPS-Aufnahme im Aufnahme-Tab.")
                )
            } else {
                List {
                    ForEach(displayedRecordings) { recording in
                        NavigationLink(destination: RecordingDetailView(recording: recording)) {
                            RecordingRowView(recording: recording)
                        }
                    }
                    .onDelete(perform: isPreview ? nil : onDelete)
                    if isPreview {
                        NavigationLink("Alle anzeigen") {
                            AllRecordingsView()
                        }
                        .padding(.vertical, 8.0)
                    }
                }
            }
        }
    }
}

#Preview {
    return NavigationStack {
        RecordingsListView(isLoading: false, isPreview: true, recordings: [
            Recording(
                name: "Testaufnahme 1",
                startDate: Date().addingTimeInterval(-3600),
                endDate: Date(),
                coordinates: [
                    Coordinate(latitude: 52.52, longitude: 13.405),
                    Coordinate(latitude: 52.521, longitude: 13.406),
                    Coordinate(latitude: 52.522, longitude: 13.407)
                ],
                bikePitchAngles: [
                    PitchAngle(timestamp: Date().addingTimeInterval(-2), angle: 5),
                    PitchAngle(timestamp: Date().addingTimeInterval(-1), angle: 4),
                    PitchAngle(timestamp: Date(), angle: 5)
                ],
                wheelies: [
                    Wheelie(startDate: Date().addingTimeInterval(-3400), endDate: Date().addingTimeInterval(-3390)),
                    Wheelie(startDate: Date().addingTimeInterval(-3200), endDate: Date().addingTimeInterval(-3185)),
                    Wheelie(startDate: Date().addingTimeInterval(-2800), endDate: Date().addingTimeInterval(-2790))
                ]
            ),
            Recording(
                name: "Testaufnahme 2",
                startDate: Date().addingTimeInterval(-3600),
                endDate: Date(),
                coordinates: [
                    Coordinate(latitude: 52.52, longitude: 13.405),
                    Coordinate(latitude: 52.521, longitude: 13.406),
                    Coordinate(latitude: 52.522, longitude: 13.407)
                ],
                bikePitchAngles: [
                    PitchAngle(timestamp: Date().addingTimeInterval(-2), angle: 5),
                    PitchAngle(timestamp: Date().addingTimeInterval(-1), angle: 4),
                    PitchAngle(timestamp: Date(), angle: 5)
                ],
                wheelies: [
                    Wheelie(startDate: Date().addingTimeInterval(-3400), endDate: Date().addingTimeInterval(-3390)),
                    Wheelie(startDate: Date().addingTimeInterval(-3200), endDate: Date().addingTimeInterval(-3185)),
                    Wheelie(startDate: Date().addingTimeInterval(-2800), endDate: Date().addingTimeInterval(-2790))
                ]
            ),
            Recording(
                name: "Testaufnahme 3",
                startDate: Date().addingTimeInterval(-3600),
                endDate: Date(),
                coordinates: [
                    Coordinate(latitude: 52.52, longitude: 13.405),
                    Coordinate(latitude: 52.521, longitude: 13.406),
                    Coordinate(latitude: 52.522, longitude: 13.407)
                ],
                bikePitchAngles: [
                    PitchAngle(timestamp: Date().addingTimeInterval(-2), angle: 5),
                    PitchAngle(timestamp: Date().addingTimeInterval(-1), angle: 4),
                    PitchAngle(timestamp: Date(), angle: 5)
                ],
                wheelies: [
                    Wheelie(startDate: Date().addingTimeInterval(-3400), endDate: Date().addingTimeInterval(-3390)),
                    Wheelie(startDate: Date().addingTimeInterval(-3200), endDate: Date().addingTimeInterval(-3185)),
                    Wheelie(startDate: Date().addingTimeInterval(-2800), endDate: Date().addingTimeInterval(-2790))
                ]
            ),
            Recording(
                name: "Testaufnahme 4",
                startDate: Date().addingTimeInterval(-3600),
                endDate: Date(),
                coordinates: [
                    Coordinate(latitude: 52.52, longitude: 13.405),
                    Coordinate(latitude: 52.521, longitude: 13.406),
                    Coordinate(latitude: 52.522, longitude: 13.407)
                ],
                bikePitchAngles: [
                    PitchAngle(timestamp: Date().addingTimeInterval(-2), angle: 5),
                    PitchAngle(timestamp: Date().addingTimeInterval(-1), angle: 4),
                    PitchAngle(timestamp: Date(), angle: 5)
                ],
                wheelies: [
                    Wheelie(startDate: Date().addingTimeInterval(-3400), endDate: Date().addingTimeInterval(-3390)),
                    Wheelie(startDate: Date().addingTimeInterval(-3200), endDate: Date().addingTimeInterval(-3185)),
                    Wheelie(startDate: Date().addingTimeInterval(-2800), endDate: Date().addingTimeInterval(-2790))
                ]
            )
        ])
    }
}
