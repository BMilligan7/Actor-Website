import Foundation

protocol Storage {
    func setDate(_ value: Date?, forKey key: String)
    func date(forKey key: String) -> Date?
    func appendStairEvents(_ events: [StairEvent])
    func recentStairEvents(limit: Int) -> [StairEvent]
}

final class UserDefaultsStorage: Storage {
    private let defaults = UserDefaults.standard
    private let stairEventsKey = "storage.stairs.events"

    func setDate(_ value: Date?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func date(forKey key: String) -> Date? {
        defaults.object(forKey: key) as? Date
    }

    func appendStairEvents(_ events: [StairEvent]) {
        guard !events.isEmpty else { return }
        var existing: [StairEvent] = recentStairEvents(limit: Int.max)
        existing.append(contentsOf: events)
        if let data = try? JSONEncoder().encode(existing) {
            defaults.set(data, forKey: stairEventsKey)
        }
    }

    func recentStairEvents(limit: Int) -> [StairEvent] {
        guard let data = defaults.data(forKey: stairEventsKey),
              let decoded = try? JSONDecoder().decode([StairEvent].self, from: data) else { return [] }
        if decoded.count <= limit { return decoded }
        return Array(decoded.suffix(limit))
    }
}



