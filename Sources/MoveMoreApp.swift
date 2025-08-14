import SwiftUI
import UIKit
import BackgroundTasks
import UserNotifications

@main
struct MoveMoreApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(AppEnvironment.shared)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                    AppEnvironment.shared.nudgeEngine.registerNotificationCategories()
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let backgroundRefreshTaskIdentifier = "com.bdm.movemore.refresh.motion"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        registerBackgroundTasks()
        scheduleNextRefresh()
        return true
    }

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundRefreshTaskIdentifier, using: nil) { task in
            AppEnvironment.shared.processBackgroundRefresh { success in
                task.setTaskCompleted(success: success)
                self.scheduleNextRefresh()
            }
        }
    }

    private func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundRefreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            #if DEBUG
            print("BGTask submit error: \(error)")
            #endif
        }
    }
}

// MARK: - Environment

final class AppEnvironment: ObservableObject {
    static let shared = AppEnvironment()

    let config: AppConfig
    let storage: Storage
    let nudgeEngine: NudgeEngine
    let motionIngestor: MotionIngestor
    let activityIngestor: ActivityIngestor
    let locationIngestor: LocationIngestor

    private init() {
        self.config = AppConfigLoader.load()
        self.storage = UserDefaultsStorage()
        self.nudgeEngine = NudgeEngine(config: config, storage: storage)
        self.motionIngestor = MotionIngestor(storage: storage)
        self.activityIngestor = ActivityIngestor(storage: storage)
        self.locationIngestor = LocationIngestor()
    }

    func processBackgroundRefresh(completion: @escaping (Bool) -> Void) {
        // For MVP scaffold: perform a lightweight pipeline call; wire real ingestion later.
        motionIngestor.backfillSinceLast { _ in
            self.activityIngestor.backfillSinceLast { _ in
                // Example trigger: evaluate sedentary nudge placeholder
                let exampleStreak = SedentaryStreak(id: UUID(), start: Date().addingTimeInterval(-60*60), end: Date(), durationMin: 60, nudged: false, resolvedByWalk: false)
                self.nudgeEngine.maybeNudgeForSedentaryStreak(exampleStreak)
                completion(true)
            }
        }
    }
}

// MARK: - UI

struct HomeView: View {
    @EnvironmentObject private var env: AppEnvironment

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today")) {
                    TileRow(title: "Walk bouts", value: "–")
                    TileRow(title: "Flights (up/down)", value: "– / –")
                    TileRow(title: "Commute minutes", value: "–")
                }
                Section(header: Text("Actions")) {
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                    }
                    Button("Start background sensors") {
                        env.locationIngestor.start {
                            env.processBackgroundRefresh { _ in }
                        }
                    }
                }
            }
            .navigationTitle("Move More")
        }
    }
}

struct TileRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsView: View {
    @State private var microWalksEnabled: Bool = true
    @State private var stairsEnabled: Bool = true
    @State private var commuteEnabled: Bool = true
    @State private var quietStart: String = "21:00"
    @State private var quietEnd: String = "07:00"
    @State private var maxNudges: Int = 4

    var body: some View {
        Form {
            Section(header: Text("Habits")) {
                Toggle("Micro-walks", isOn: $microWalksEnabled)
                Toggle("Stairs", isOn: $stairsEnabled)
                Toggle("Commute", isOn: $commuteEnabled)
            }
            Section(header: Text("Notifications")) {
                Stepper("Max nudges/day: \(maxNudges)", value: $maxNudges, in: 0...10)
                HStack {
                    Text("Quiet start")
                    Spacer()
                    Text(quietStart)
                }
                HStack {
                    Text("Quiet end")
                    Spacer()
                    Text(quietEnd)
                }
            }
        }
        .navigationTitle("Settings")
    }
}


