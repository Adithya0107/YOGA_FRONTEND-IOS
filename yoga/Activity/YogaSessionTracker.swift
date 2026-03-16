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
        // Cap active seconds at target time (minPracticeTime)
        if activeSeconds < minRequiredSeconds {
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
    
    func calculateCalories() -> Int {
        // Simple formula: duration in mins * intensity factor (yoga is ~3-5 cal/min)
        return (activeSeconds / 60) * 4
    }
}
