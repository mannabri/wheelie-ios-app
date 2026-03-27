//
//  LocationManager.swift
//  Wheelie
//
//  Service für GPS-Standortverfolgung
//

import Foundation
import CoreLocation
import Combine

/// Verwaltet die GPS-Standortverfolgung
class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    @Published var isTracking: Bool = false
    
    // MARK: - Private Properties
    
    private var locationManager: CLLocationManager?
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    
    /// Prüft, ob wir im Preview-Kontext laufen
    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        // Im Preview keine CLLocationManager-Instanz erstellen
        guard !Self.isPreview else { return }
        setupLocationManager()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 0 // Mindestdistanz in Metern für Updates
        manager.pausesLocationUpdatesAutomatically = false
        self.locationManager = manager
    }
    
    // MARK: - Public Methods
    
    /// Fragt Berechtigung für Standortzugriff an
    func requestAuthorization() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    /// Startet GPS-Tracking
    func startTracking(onLocationUpdate: @escaping (CLLocation) -> Void) {
        locationUpdateHandler = onLocationUpdate
        locationManager?.startUpdatingLocation()
        isTracking = true
    }
    
    /// Stoppt GPS-Tracking
    func stopTracking() {
        locationManager?.stopUpdatingLocation()
        locationUpdateHandler = nil
        isTracking = false
    }
    
    /// Pausiert GPS-Tracking (behält Handler bei)
    func pauseTracking() {
        locationManager?.stopUpdatingLocation()
        isTracking = false
    }
    
    /// Setzt GPS-Tracking fort
    func resumeTracking() {
        locationManager?.startUpdatingLocation()
        isTracking = true
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filtere ungenaue Standorte
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 50 else { return }
        
        currentLocation = location
        locationUpdateHandler?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        print("Location Error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
