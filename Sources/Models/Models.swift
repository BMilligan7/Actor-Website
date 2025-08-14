import Foundation
import CoreLocation

public struct WalkBout: Codable, Identifiable, Hashable {
    public let id: UUID
    public let start: Date
    public let end: Date
    public let steps: Int
    public let distanceM: Double
    public let avgCadenceSPM: Double
    public let label: BoutLabel
    public let createdAt: Date

    public enum BoutLabel: String, Codable { case none, auto, user }
}

public struct SedentaryStreak: Codable, Identifiable, Hashable {
    public let id: UUID
    public let start: Date
    public let end: Date
    public let durationMin: Int
    public let nudged: Bool
    public let resolvedByWalk: Bool
}

public struct StairEvent: Codable, Identifiable, Hashable {
    public let id: UUID
    public let timestamp: Date
    public let flightsUp: Int
    public let flightsDown: Int
    public let context: PlaceType
}

public struct CommuteSession: Codable, Identifiable, Hashable {
    public let id: UUID
    public let start: Date
    public let end: Date
    public let mode: CommuteMode
    public let distanceKm: Double
    public let medianSpeedMps: Double
}

public enum CommuteMode: String, Codable { case walk, cycle, automotive }

public struct Nudge: Codable, Identifiable, Hashable {
    public let id: UUID
    public let timestamp: Date
    public let type: NudgeType
    public let accepted: Bool
    public let snoozed: Bool
}

public enum NudgeType: String, Codable { case move, stairs, commute }

public struct Place: Codable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let type: PlaceType
    public let latitude: Double
    public let longitude: Double
    public let radiusM: Int

    public init(id: UUID = UUID(), name: String, type: PlaceType, center: CLLocationCoordinate2D, radiusM: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = center.latitude
        self.longitude = center.longitude
        self.radiusM = radiusM
    }
}

public enum PlaceType: String, Codable { case home, work, other }

public struct DailyAggregate: Codable, Hashable {
    public let date: Date
    public let walkBoutsCount: Int
    public let walkBoutMinutes: Int
    public let flightsUp: Int
    public let flightsDown: Int
    public let commuteWalkMin: Int
    public let commuteAutoMin: Int
    public let commuteCycleMin: Int
    public let longSedentaryStreaks: Int
}



