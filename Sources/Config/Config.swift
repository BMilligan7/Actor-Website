import Foundation

public struct AppConfig: Codable {
    public struct WalkBout: Codable { let minDurationSec: Int; let minSteps: Int; let minCadenceSPM: Int }
    public struct Sedentary: Codable { let streakMinMin: Int; let resolveMinSec: Int; let resolveMinSteps: Int }
    public struct Stairs: Codable { let windowMin: Int; let minDeltaFloors: Int }
    public struct Commute: Codable { let minDurationMin: Int; let minDisplacementKm: Double; let walkMaxMps: Double; let cycleMaxMps: Double }
    public struct Nudges: Codable { let maxPerDay: Int; let moveCooldownMin: Int; let quietStart: String; let quietEnd: String }

    let walkBout: WalkBout
    let sedentary: Sedentary
    let stairs: Stairs
    let commute: Commute
    let nudges: Nudges
}

enum AppConfigLoader {
    static func load() -> AppConfig {
        if let url = Bundle.main.url(forResource: "Config", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let cfg = try? JSONDecoder().decode(AppConfig.self, from: data) {
            return cfg
        }
        // Fallback defaults (should match Resources/Config.json)
        return AppConfig(
            walkBout: .init(minDurationSec: 60, minSteps: 60, minCadenceSPM: 60),
            sedentary: .init(streakMinMin: 45, resolveMinSec: 120, resolveMinSteps: 150),
            stairs: .init(windowMin: 2, minDeltaFloors: 1),
            commute: .init(minDurationMin: 5, minDisplacementKm: 1, walkMaxMps: 2.0, cycleMaxMps: 8.0),
            nudges: .init(maxPerDay: 4, moveCooldownMin: 90, quietStart: "21:00", quietEnd: "07:00")
        )
    }
}




