//
//  Wheelie.swift
//  Wheelie
//
//  Wheelie detection model - Represents a wheelie with start and end dates

import Foundation

/// Represents a single wheelie with start and end timestamps
struct Wheelie: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    var endDate: Date?
    
    init(id: UUID = UUID(), startDate: Date = Date(), endDate: Date? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // MARK: - Computed Properties
    
    /// Duration of the wheelie in seconds
    var duration: TimeInterval {
        guard let end = endDate else { return 0 }
        return end.timeIntervalSince(startDate)
    }
    
    /// Formatted duration as string (MM:SS or just seconds)
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%d s", seconds)
        }
    }
    
    /// Whether the wheelie is still ongoing (no end date)
    var isOngoing: Bool {
        endDate == nil
    }
}
