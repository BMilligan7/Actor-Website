import Foundation
import CoreMotion

final class MotionIngestor {
    private let pedometer = CMPedometer()
    private let storage: Storage
    private let lastProcessedKey = "motion.lastPedometerProcessedAt"
    private let config: AppConfig

    init(storage: Storage, config: AppConfig) {
        self.storage = storage
        self.config = config
    }

    func backfillSinceLast(completion: @escaping (Bool) -> Void) {
        guard CMPedometer.isStepCountingAvailable() else { completion(false); return }
        let until = Date()
        let defaultSince = Calendar.current.date(byAdding: .hour, value: -24, to: until) ?? until
        let since = storage.date(forKey: lastProcessedKey) ?? defaultSince
        pedometer.queryPedometerData(from: since, to: until) { data, error in
            let success = (error == nil)
            if let d = data {
                let stairsWindows = MotionIngestor.makeStairsWindows(from: d, since: since, until: until)
                let events = StairDetector.detectEvents(
                    windows: stairsWindows,
                    windowMin: self.config.stairs.windowMin,
                    minDeltaFloors: self.config.stairs.minDeltaFloors,
                    context: .other
                )
                self.storage.appendStairEvents(events)
            }
            if success {
                self.storage.setDate(until, forKey: self.lastProcessedKey)
            }
            completion(success)
        }
    }

    private static func makeStairsWindows(from data: CMPedometerData, since: Date, until: Date) -> [StairsWindow] {
        var up = 0
        var down = 0
        if let floorsAscended = data.floorsAscended?.intValue { up = max(0, floorsAscended) }
        if let floorsDescended = data.floorsDescended?.intValue { down = max(0, floorsDescended) }
        guard up > 0 || down > 0 else { return [] }
        return [StairsWindow(start: since, end: until, floorsUp: up, floorsDown: down)]
    }
}


