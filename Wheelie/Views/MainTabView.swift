//
//  MainTabView.swift
//  Wheelie
//
//  Haupt-TabView mit Navigation zwischen Aufnahme und Übersicht
//

import SwiftUI

/// Haupt-Navigation der App
struct MainTabView: View {
    @State private var isRecordingActive = false
    @State private var navigationPath = NavigationPath()
    @State private var recordingToShow: Recording?

    var body: some View {
        TabView {
            Tab("Übersicht", systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                }
                .toolbar(isRecordingActive ? .hidden : .visible, for: .tabBar)
            }
            Tab("Aufnahme", systemImage: "record.circle") {
                NavigationStack(path: $navigationPath) {
                    RecordingView(
                        isRecordingActive: $isRecordingActive,
                        onRecordingFinished: { recording in
                            recordingToShow = recording
                            navigationPath.append("RecordingDetail")
                        }
                    )
                    .navigationBarHidden(true)
                    .navigationDestination(for: String.self) { destination in
                        if destination == "RecordingDetail", let recording = recordingToShow {
                            RecordingDetailView(recording: recording)
                        }
                    }
                }
                .toolbar(isRecordingActive ? .hidden : .visible, for: .tabBar)
            }
        }
    }
}

#Preview {
    MainTabView()
}
