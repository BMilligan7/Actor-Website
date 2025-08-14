import Foundation

protocol Storage {
    func setDate(_ value: Date?, forKey key: String)
    func date(forKey key: String) -> Date?
}

final class UserDefaultsStorage: Storage {
    private let defaults = UserDefaults.standard

    func setDate(_ value: Date?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func date(forKey key: String) -> Date? {
        defaults.object(forKey: key) as? Date
    }
}



