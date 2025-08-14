import Foundation
import UserNotifications

final class NudgeEngine {
    private let config: AppConfig
    private let storage: Storage
    private let moveLastNudgeKey = "nudge.move.lastAt"
    private let moveDailyCountKeyPrefix = "nudge.move.count."

    init(config: AppConfig, storage: Storage) {
        self.config = config
        self.storage = storage
    }

    // MARK: - Public API

    func maybeNudgeForSedentaryStreak(_ streak: SedentaryStreak, now: Date = Date()) {
        guard streak.durationMin >= config.sedentary.streakMinMin else { return }
        guard !isWithinQuietHours(now: now) else { return }
        guard canFireMoveNudge(now: now) else { return }
        scheduleLocalNotification(
            title: "Been still ~\(config.sedentary.streakMinMin) min.",
            body: "2-min lap now?",
            categoryIdentifier: "MOVE"
        )
        recordMoveNudge(now: now)
    }

    // MARK: - Quiet Hours

    func isWithinQuietHours(now: Date = Date()) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        guard let start = formatter.date(from: config.nudges.quietStart),
              let end = formatter.date(from: config.nudges.quietEnd) else { return false }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        guard let todayTime = formatter.date(from: String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)) else { return false }

        if start <= end {
            return (start ... end).contains(todayTime)
        } else {
            // Overnight window, e.g., 21:00–07:00
            return todayTime >= start || todayTime <= end
        }
    }

    // MARK: - Cooldowns & Limits

    private func canFireMoveNudge(now: Date) -> Bool {
        // Cooldown
        if let last = storage.date(forKey: moveLastNudgeKey) {
            let minInterval = TimeInterval(config.nudges.moveCooldownMin * 60)
            if now.timeIntervalSince(last) < minInterval { return false }
        }
        // Max per day
        let key = dailyCountKey(for: now)
        let count = UserDefaults.standard.integer(forKey: key)
        return count < config.nudges.maxPerDay
    }

    private func recordMoveNudge(now: Date) {
        storage.setDate(now, forKey: moveLastNudgeKey)
        let key = dailyCountKey(for: now)
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }

    private func dailyCountKey(for date: Date) -> String {
        let ymd = DateFormatter.cachedYMD.string(from: date)
        return moveDailyCountKeyPrefix + ymd
    }

    // MARK: - Local Notifications

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func registerNotificationCategories() {
        let startAction = UNNotificationAction(identifier: "MOVE_START_TIMER", title: "Start Timer", options: [])
        let snoozeAction = UNNotificationAction(identifier: "MOVE_SNOOZE", title: "Snooze 60 min", options: [])
        let moveCategory = UNNotificationCategory(identifier: "MOVE", actions: [startAction, snoozeAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([moveCategory])
    }

    private func scheduleLocalNotification(title: String, body: String, categoryIdentifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

// MARK: - DateFormatter cache

private extension DateFormatter {
    static let cachedYMD: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

// MARK: - Lightweight detector scaffolds (placeholders)

// Represents a joined pedometer/activity window used for bout detection
public struct MotionWindow: Equatable {
    public let start: Date
    public let end: Date
    public let steps: Int
    public let distanceM: Double
    public let avgCadenceSPM: Double
    public let isWalkingMajority: Bool

    public init(start: Date, end: Date, steps: Int, distanceM: Double, avgCadenceSPM: Double, isWalkingMajority: Bool) {
        self.start = start
        self.end = end
        self.steps = steps
        self.distanceM = distanceM
        self.avgCadenceSPM = avgCadenceSPM
        self.isWalkingMajority = isWalkingMajority
    }
}

struct WalkBoutDetector {
    /// Detects walk bouts by merging consecutive walking-majority windows and applying thresholds.
    /// - Parameters:
    ///   - windows: Time-ordered motion windows (order is enforced inside).
    ///   - minDurationSec: Minimum bout duration in seconds.
    ///   - minSteps: Minimum total steps in bout.
    ///   - minCadenceSPM: Minimum average cadence in steps per minute.
    static func detectBouts(windows: [MotionWindow], minDurationSec: Int, minSteps: Int, minCadenceSPM: Int, createdAt: Date = Date()) -> [WalkBout] {
        guard !windows.isEmpty else { return [] }

        let sorted = windows.sorted { $0.start < $1.start }
        var bouts: [WalkBout] = []

        var currentStart: Date?
        var currentEnd: Date?
        var currentSteps = 0
        var currentDistanceM: Double = 0

        func flushIfBout() {
            guard let s = currentStart, let e = currentEnd else { return }
            let durationSec = max(0, Int(e.timeIntervalSince(s)))
            guard durationSec >= minDurationSec else { reset() ; return }
            let durationMin = max(1e-6, Double(durationSec) / 60.0)
            let avgCadence = Double(currentSteps) / durationMin
            let passes = currentSteps >= minSteps || Int(avgCadence.rounded()) >= minCadenceSPM
            guard passes else { reset() ; return }
            let bout = WalkBout(
                id: UUID(),
                start: s,
                end: e,
                steps: currentSteps,
                distanceM: currentDistanceM,
                avgCadenceSPM: avgCadence,
                label: .auto,
                createdAt: createdAt
            )
            bouts.append(bout)
            reset()
        }

        func reset() {
            currentStart = nil
            currentEnd = nil
            currentSteps = 0
            currentDistanceM = 0
        }

        for w in sorted {
            if w.isWalkingMajority {
                if currentStart == nil { currentStart = w.start }
                currentEnd = max(currentEnd ?? w.end, w.end)
                currentSteps += w.steps
                currentDistanceM += w.distanceM
            } else {
                // Non-walking breaks the current segment
                flushIfBout()
            }
        }

        // Flush tail segment
        flushIfBout()

        return bouts
    }
}

struct StairDetector {
    static func detectStairs(minDeltaFloors: Int) -> [StairEvent] {
        // Placeholder: compute floors deltas over windows
        return []
    }
}

struct CommuteDetector {
    static func detectSessions() -> [CommuteSession] {
        // Placeholder: sessionization logic
        return []
    }
}


