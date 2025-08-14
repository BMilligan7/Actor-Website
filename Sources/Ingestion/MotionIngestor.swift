import Foundation
import CoreMotion

final class MotionIngestor {
    private let pedometer = CMPedometer()
    private let storage: Storage
    private let lastProcessedKey = "motion.lastPedometerProcessedAt"

    init(storage: Storage) {
        self.storage = storage
    }

    func backfillSinceLast(completion: @escaping (Bool) -> Void) {
        guard CMPedometer.isStepCountingAvailable() else { completion(false); return }
        let until = Date()
        let defaultSince = Calendar.current.date(byAdding: .hour, value: -24, to: until) ?? until
        let since = storage.date(forKey: lastProcessedKey) ?? defaultSince
        pedometer.queryPedometerData(from: since, to: until) { _, error in
            let success = (error == nil)
            if success {
                self.storage.setDate(until, forKey: self.lastProcessedKey)
            }
            completion(success)
        }
    }
}


