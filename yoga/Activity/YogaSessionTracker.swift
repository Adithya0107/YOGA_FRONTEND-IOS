import SwiftUI
import Combine

class YogaSessionTracker: ObservableObject {
    @Published var isSessionActive = false
    @Published var startTime: Date?
    @Published var activeSeconds: Int = 0
    @Published var watchedSeconds: Int = 0
    @Published var lastPauseDate: Date?
    @Published var totalInactivitySeconds: Int = 0
    
    private var timer: AnyCancellable?
    private var inactivityTimer: AnyCancellable?
    private var backgroundDate: Date?
    
    let style: YogaStyle
    let minRequiredSeconds: Int
    
    init(style: YogaStyle) {
        self.style = style
        self.minRequiredSeconds = style.level.minPracticeTime
    }
    
    func startSession() {
        isSessionActive = true
        startTime = Date()
        activeSeconds = 0
        watchedSeconds = 0
        totalInactivitySeconds = 0
    }
    
    func stopSession() {
        isSessionActive = false
    }
    
    func tick() {
        guard isSessionActive else { return }
        // Cap active seconds at total duration
        if activeSeconds < style.totalDuration {
            activeSeconds += 1
        }
        watchedSeconds += 1
    }
    
    private func setupInactivityMonitoring() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.backgroundDate = Date()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self, let bgDate = self.backgroundDate else { return }
            let bgDuration = Date().timeIntervalSince(bgDate)
            if bgDuration > 60 {
                // If backgrounded for more than 60s, don't count it as active seconds.
                // In this simplified model, we'd ideally pause, but for now we track as inactivity.
                self.totalInactivitySeconds += Int(bgDuration)
            }
            self.backgroundDate = nil
        }
    }
    
    func calculateStatus() -> SessionStatus {
        let minRequired = style.level.minPracticeTime
        
        if activeSeconds >= minRequired {
            return .completed
        } else if activeSeconds >= (minRequired / 2) {
            return .partial
        } else {
            return .failed
        }
    }
    
    private let yogaCalories: [String: Int] = [
        "Morning Weight Loss Yoga": 120,
        "Foundation Strength": 95,
        "Gentle Flexibility": 60,
        "Evening Zen": 45,
        "Pranayama Basics": 35,
        "Power Vinyasa Flow": 180,
        "Core & Balance Lab": 150,
        "Flow and Lengthen": 110,
        "Inner Harmonic Yoga": 90,
        "Active Breath Mastery": 70,
        "Metabolic HIIT Yoga": 260,
        "Advanced Arm Balanced": 220,
        "Full Body Alchemy": 240,
        "Meditation in Motion": 100,
        "Virtual Energy Unlock Yoga": 170,
        "Vinyasa Flow": 180,
        "Hatha Yoga": 80,
        "Power Yoga": 220,
        "Restorative Yoga": 50,
        "Yin Yoga Relief": 45
    ]
    
    func calculateCalories() -> Int {
        // Assume default 10 calories per minute if not in map
        // Listed calories are for a typical session (let's assume 20 mins)
        let totalCals = yogaCalories[style.name] ?? 200
        let caloriesPerMinute = Double(totalCals) / 20.0
        let minutes = Double(activeSeconds) / 60.0
        return Int(minutes * caloriesPerMinute)
    }
}
