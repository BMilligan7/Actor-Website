import Foundation
import CoreLocation

final class LocationIngestor: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var onWake: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = true
    }

    func start(onWake: @escaping () -> Void) {
        self.onWake = onWake
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
        if #available(iOS 13.0, *) {
            manager.startMonitoringVisits()
        }
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        onWake?()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Significant-change updates arrive here
        onWake?()
    }
}


