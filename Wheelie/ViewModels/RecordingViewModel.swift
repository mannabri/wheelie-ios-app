//
//  RecordingViewModel.swift
//  Wheelie
//
//  ViewModel für GPS-Aufnahme (Starten, Pausieren, Beenden)
//

import Foundation
import CoreLocation
import Combine

/// ViewModel für die aktive GPS-Aufnahme
@MainActor
class RecordingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentRecording: Recording?
    @Published var isRecording: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentLocation: CLLocation?
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let locationManager: LocationManager
    private let storageManager: StorageManager
    private let deviceOrientationManager: DeviceOrientationManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Properties
    
    private var onRecordingFinishedCallback: ((Recording) -> Void)?
    private var lastBikePitchAngleTimestamp: Date?
    private var isInWheelieState: Bool = false // Track wheelie state
    
    // MARK: - Initialization
    
    init(locationManager: LocationManager? = nil, storageManager: StorageManager? = nil, deviceOrientationManager: DeviceOrientationManager? = nil) {
        self.locationManager = locationManager ?? LocationManager()
        self.storageManager = storageManager ?? .shared
        self.deviceOrientationManager = deviceOrientationManager ?? DeviceOrientationManager()
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLocation)
        
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    self?.errorMessage = "Standortzugriff wurde verweigert. Bitte aktiviere ihn in den Einstellungen."
                }
            }
            .store(in: &cancellables)
        
        // Bind device orientation manager pitch angle and add to recording
        deviceOrientationManager.$pitchAngle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] angle in
                self?.updateDevicePitchAngle(angle)
                self?.addBikePitchAngle(angle)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Fragt Standortberechtigung an
    func requestLocationPermission() {
        locationManager.requestAuthorization()
    }
    
    /// Fragt Berechtigung für Bewegungsdaten an
    func requestMotionPermission() {
        deviceOrientationManager.requestAuthorization()
    }
    
    /// Setzt den Callback für beendete Aufnahmen
    func setOnRecordingFinished(_ callback: @escaping (Recording) -> Void) {
        onRecordingFinishedCallback = callback
    }
    
    /// Startet eine neue GPS-Aufnahme
    func startRecording() {
        var recording = Recording(startDate: Date(), status: .recording)
        recording.initialDevicePitchAngle = deviceOrientationManager.pitchAngle
        currentRecording = recording
        isRecording = true
        isPaused = false
        
        deviceOrientationManager.startMonitoring()
        
        locationManager.startTracking { [weak self] location in
            Task { @MainActor in
                self?.addCoordinate(from: location)
            }
        }
    }
    
    /// Pausiert die aktuelle Aufnahme
    func pauseRecording() {
        guard var recording = currentRecording else { return }
        
        recording.status = .paused
        currentRecording = recording
        isPaused = true
        lastBikePitchAngleTimestamp = nil // Reset timestamp
        
        locationManager.pauseTracking()
    }
    
    /// Setzt die pausierte Aufnahme fort
    func resumeRecording() {
        guard var recording = currentRecording else { return }
        
        recording.status = .recording
        currentRecording = recording
        isPaused = false
        
        locationManager.resumeTracking()
    }
    
    /// Beendet und speichert die Aufnahme
    func stopRecording() {
        guard var recording = currentRecording else { return }
        
        recording.status = .stopped
        recording.endDate = Date()
        
        locationManager.stopTracking()
        deviceOrientationManager.stopMonitoring()
        
        
        do {
            try storageManager.saveRecording(recording)
            onRecordingFinishedCallback?(recording)
            errorMessage = nil
        } catch {
            let nsError = error as NSError
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription) (Domain: \(nsError.domain), Code: \(nsError.code))"
            print("Storage error details: \(error)")
        }
        
        currentRecording = nil
        isRecording = false
        isPaused = false
    }
    
    /// Verwirft die aktuelle Aufnahme ohne Speichern
    func discardRecording() {
        locationManager.stopTracking()
        deviceOrientationManager.stopMonitoring()
        currentRecording = nil
        isRecording = false
        isPaused = false
    }
    
    // MARK: - Private Methods
    
    private func addCoordinate(from location: CLLocation) {
        guard var recording = currentRecording else { return }
        
        let coordinate = Coordinate(from: location)
        recording.coordinates.append(coordinate)
        currentRecording = recording
    }
    
    private func updateDevicePitchAngle(_ angle: Double) {
        guard var recording = currentRecording else { return }
        recording.devicePitchAngle = angle
        currentRecording = recording
    }
    
    private func addBikePitchAngle(_ angle: Double) {
        guard var recording = currentRecording, isRecording else { return }
        guard let initialAngle = recording.initialDevicePitchAngle else { return }
        
        // Initialize timestamp on first call
        if lastBikePitchAngleTimestamp == nil {
            lastBikePitchAngleTimestamp = Date()
        }
        
        // Only add bike pitch angle if at least 0.1 seconds has passed since the last addition
        guard let lastTimestamp = lastBikePitchAngleTimestamp else { return }
        let timeSinceLastAddition = Date().timeIntervalSince(lastTimestamp)
        guard timeSinceLastAddition >= 0.1 else { return }
        
        let bikePitchAngle = angle - initialAngle
        let bikePitchAngleObject = PitchAngle(timestamp: Date(), angle: max(0.0, bikePitchAngle))
        recording.bikePitchAngles.append(bikePitchAngleObject)
        
        // Detect wheelie state
        recording.isWheelie = detectWheelieState(bikePitchAngle: max(0.0, bikePitchAngle))
        
        currentRecording = recording
        lastBikePitchAngleTimestamp = Date()
    }
    
    private func detectWheelieState(bikePitchAngle: Double) -> Bool {
        // Wheelie detection thresholds:
        // - Enter wheelie when pitch angle >= 15°
        // - Exit wheelie when pitch angle < 5°
        // - Once in wheelie, can drop below 15° but stays in wheelie until < 5°
        
        if bikePitchAngle >= 15.0 {
            // Enter or stay in wheelie
            isInWheelieState = true
        } else if bikePitchAngle < 5.0 {
            // Exit wheelie
            isInWheelieState = false
        }
        // If 5° <= angle < 15°, maintain current wheelie state
        
        return isInWheelieState
    }
}
