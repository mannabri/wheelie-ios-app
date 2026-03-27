//
//  DeviceOrientationManager.swift
//  Wheelie
//
//  Manages device orientation and rotation tracking using CoreMotion
//

import Foundation
import CoreMotion
import Combine

/// Manages device orientation and rotation tracking
@MainActor
class DeviceOrientationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current pitch angle in degrees (x-axis rotation)
    /// Positive when tilting device backwards (away from user)
    /// Negative when tilting device forwards (towards user)
    @Published var pitchAngle: Double = 0.0
    
    // MARK: - Private Properties
    
    private let motionManager = CMMotionManager()
    private let operationQueue = OperationQueue()
    
    /// Prüft, ob wir im Preview-Kontext laufen
    private static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    private func setupMotionManager() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.016 // ~60 FPS
        
        // Start updating device motion
        motionManager.startDeviceMotionUpdates(to: operationQueue) { [weak self] motion, error in
            guard let motion = motion, error == nil else { return }
            
            // Convert attitude pitch (radians) to degrees
            // pitch ranges from -π to π, we convert to degrees
            let pitchDegrees = motion.attitude.pitch * 180 / .pi
            
            Task { @MainActor in
                self?.pitchAngle = pitchDegrees
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests permission to access device motion data
    /// Note: On iOS 17+, this shows a permission dialog.
    /// On earlier versions, motion data access is granted by default if app is in foreground.
    func requestAuthorization() {
        guard !Self.isPreview else { return }
        
        // On iOS 17+, request authorization for motion data
        // On earlier versions, motion data access is granted by default if app is in foreground
        // The NSMotionUsageDescription in Info.plist satisfies the requirement
        if #available(iOS 17.0, *) {
            // Motion authorization is handled automatically on iOS 17+
            // when the user grants permission via the system dialog
        }
        
        // Attempt to start monitoring - this will work if authorized
        startMonitoring()
    }
    
    /// Starts monitoring device orientation
    func startMonitoring() {
        if !motionManager.isDeviceMotionActive {
            setupMotionManager()
        }
    }
    
    /// Stops monitoring device orientation
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    nonisolated private func cleanupMotionManager(_ manager: CMMotionManager) {
        // This can be called from deinit which is nonisolated
        Task { @MainActor in
            manager.stopDeviceMotionUpdates()
        }
    }
    
    deinit {
        cleanupMotionManager(motionManager)
    }
}
