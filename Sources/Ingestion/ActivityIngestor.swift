import Foundation
import CoreMotion

final class ActivityIngestor {
    private let manager = CMMotionActivityManager()
    private let storage: Storage
    private let lastProcessedKey = "motion.lastActivityProcessedAt"

    init(storage: Storage) {
        self.storage = storage
    }

    func backfillSinceLast(completion: @escaping (Bool) -> Void) {
        guard CMMotionActivityManager.isActivityAvailable() else { completion(false); return }
        let until = Date()
        let defaultSince = Calendar.current.date(byAdding: .hour, value: -24, to: until) ?? until
        let since = storage.date(forKey: lastProcessedKey) ?? defaultSince
        manager.queryActivityStarting(from: since, to: until, to: .main) { _, error in
            let success = (error == nil)
            if success {
                self.storage.setDate(until, forKey: self.lastProcessedKey)
            }
            completion(success)
        }
    }
}


