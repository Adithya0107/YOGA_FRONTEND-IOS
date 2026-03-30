import SwiftUI
import Combine

enum ActivityStatus: String, Codable {
    case completed // Full Day
    case halfDay   // Half Day
    case notDone   // Not Done
    case restDay
    case injury
    
    var color: Color {
        switch self {
        case .completed: return .green
        case .halfDay: return Color(red: 134/255, green: 239/255, blue: 172/255) // Lighter green
        case .notDone: return .red
        case .restDay: return .purple
        case .injury: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .completed: return "checkmark.circle.fill"
        case .halfDay: return "circle.lefthalf.filled"
        case .notDone: return "xmark.circle.fill"
        case .restDay: return "moon.zzz.fill"
        case .injury: return "exclamationmark.triangle.fill"
        }
    }
}

struct ActivityEntry: Codable {
    let date: Date
    var status: ActivityStatus
    var note: String?
}

struct WatchHistoryEntry: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String
    var watchedSeconds: Int
    var watchedFormatted: String {
        let m = watchedSeconds / 60
        let s = watchedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    let date: Date
    var completed: Bool
    var thumbnailUrl: String? = nil
}

class ActivityManager: ObservableObject {
    static let shared = ActivityManager()
    
    @AppStorage("user_activity_data") private var activityDataJSON: String = "[]"
    @Published var activities: [Date: ActivityEntry] = [:]
    
    @AppStorage("session_records") private var sessionRecordsJSON: String = "[]"
    @Published var sessionRecords: [SessionRecord] = []
    
    @AppStorage("watch_history_data") private var watchHistoryJSON: String = "[]"
    @Published var watchHistory: [WatchHistoryEntry] = []
    
    @AppStorage("total_practice_minutes") var totalPracticeMinutes: Int = 0
    @AppStorage("total_calories") var totalCalories: Int = 0
    @AppStorage("current_streak") var currentStreak: Int = 0
    @AppStorage("screen_time_minutes") var screenTimeMinutes: Int = 0
    private var screenTimeSeconds: Int = 0
    
    var totalSessions: Int {
        // Count unique video titles in history
        Set(watchHistory.map { $0.title }).count
    }
    
    var proLevel: Int {
        if currentStreak >= 150 { return 5 } // 5 months
        if currentStreak >= 90 { return 4 }  // 3 months
        if currentStreak >= 60 { return 3 }  // 2 months
        if currentStreak >= 30 { return 2 }  // 1 month
        if currentStreak >= 15 { return 1 }  // 15 days
        return 0
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        loadSessionRecords()
        loadWatchHistory()
        startScreenTimeTracking()
    }
    
    private func startScreenTimeTracking() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.screenTimeSeconds += 1
            if self.screenTimeSeconds >= 60 {
                self.screenTimeMinutes += 1
                self.screenTimeSeconds = 0
            }
        }
    }
    
    private func loadSessionRecords() {
        guard let data = sessionRecordsJSON.data(using: .utf8) else { return }
        sessionRecords = (try? JSONDecoder().decode([SessionRecord].self, from: data)) ?? []
    }
    
    private func loadWatchHistory() {
        guard let data = watchHistoryJSON.data(using: .utf8) else { return }
        watchHistory = (try? JSONDecoder().decode([WatchHistoryEntry].self, from: data)) ?? []
        updateTotalStats()
    }
    
    @AppStorage("resume_positions") private var resumePositionsJSON: String = "{}"
    
    func saveWatchProgress(title: String, position: Int, deltaSeconds: Int, duration: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let isCompleted = Double(position) / Double(max(1, duration)) >= 0.95
        
        // 1. Update Resume Position
        var resumes: [String: Int] = [:]
        if let resumeData = resumePositionsJSON.data(using: .utf8) {
            resumes = (try? JSONDecoder().decode([String: Int].self, from: resumeData)) ?? [:]
        }
        resumes[title] = position
        if let encoded = try? JSONEncoder().encode(resumes), let json = String(data: encoded, encoding: .utf8) {
            resumePositionsJSON = json
        }
        
        // 2. Update Daily Time Spent in History
        if let index = watchHistory.firstIndex(where: { $0.title == title && calendar.isDate($0.date, inSameDayAs: today) }) {
            watchHistory[index].watchedSeconds += deltaSeconds
            watchHistory[index].completed = watchHistory[index].completed || isCompleted
        } else {
            let newEntry = WatchHistoryEntry(
                title: title,
                watchedSeconds: deltaSeconds,
                date: today,
                completed: isCompleted
            )
            watchHistory.insert(newEntry, at: 0)
        }
        
        persistWatchHistory()
        updateTotalStats()
    }
    
    func getWatchProgress(title: String) -> Int {
        if let resumeData = resumePositionsJSON.data(using: .utf8),
           let resumes = try? JSONDecoder().decode([String: Int].self, from: resumeData) {
            return resumes[title] ?? 0
        }
        return 0
    }
    
    private func persistWatchHistory() {
        if let data = try? JSONEncoder().encode(watchHistory),
           let json = String(data: data, encoding: .utf8) {
            watchHistoryJSON = json
        }
    }
    
    private func updateTotalStats() {
        // Total minutes is sum of all watched seconds / 60
        let totalSecs = watchHistory.reduce(0) { $0 + $1.watchedSeconds }
        self.totalPracticeMinutes = totalSecs / 60
    }
    
    func addSessionRecord(_ record: SessionRecord) {
        sessionRecords.append(record)
        if let data = try? JSONEncoder().encode(sessionRecords),
           let json = String(data: data, encoding: .utf8) {
            sessionRecordsJSON = json
        }
        
        // Add calories and minutes to total
        self.totalCalories += record.caloriesBurned
        self.totalPracticeMinutes += (record.actualPracticeTime / 60)
        
        // Update Watch History to keep stats in sync
        saveWatchProgress(
            title: record.styleName,
            position: record.actualPracticeTime,
            deltaSeconds: record.actualPracticeTime,
            duration: record.totalVideoDuration
        )
        
        if record.status == .completed {
            markDate(record.date, status: .completed)
        } else if record.status == .partial {
            markDate(record.date, status: .halfDay)
        } else {
            markDate(record.date, status: .notDone)
        }
        
        // Sync to backend
        syncSessionToBackend(record)
    }
    
    private func syncSessionToBackend(_ record: SessionRecord) {
        guard let url = URL(string: "\(AppTheme.yogaBaseURL)/save_session") else { return }
        
        // Use user_id from UserDefaults if available, otherwise default to 1 for now
        let userId = UserDefaults.standard.integer(forKey: "user_id") > 0 ? UserDefaults.standard.integer(forKey: "user_id") : 1
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let body: [String: Any] = [
            "user_id": userId,
            "style_name": record.styleName,
            "level": record.level.rawValue,
            "total_duration": record.totalVideoDuration,
            "actual_duration": record.actualPracticeTime,
            "completion_percentage": record.completionPercentage,
            "status": record.status.rawValue,
            "calories": record.caloriesBurned,
            "date": formatter.string(from: record.date)
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to sync session to backend: \(error.localizedDescription)")
                return
            }
            print("Session successfully synced to backend")
        }.resume()
    }
    
    func loadData() {
        guard let data = activityDataJSON.data(using: .utf8) else { return }
        do {
            let decoded = try JSONDecoder().decode([ActivityEntry].self, from: data)
            var dict: [Date: ActivityEntry] = [:]
            let calendar = Calendar.current
            for entry in decoded {
                let date = calendar.startOfDay(for: entry.date)
                dict[date] = entry
            }
            self.activities = dict
            calculateStreak()
        } catch {
            print("Failed to decode activity data: \(error)")
        }
    }
    
    func saveData() {
        let list = Array(activities.values)
        do {
            let data = try JSONEncoder().encode(list)
            if let json = String(data: data, encoding: .utf8) {
                activityDataJSON = json
            }
            calculateStreak()
        } catch {
            print("Failed to encode activity data: \(error)")
        }
    }
    
    func markDate(_ date: Date, status: ActivityStatus, note: String? = nil) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        activities[startOfDay] = ActivityEntry(date: startOfDay, status: status, note: note)
        saveData()
    }
    
    func deleteActivity(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        activities.removeValue(forKey: startOfDay)
        saveData()
    }
    
    func calculateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Start from today or yesterday
        if activities[checkDate]?.status != .completed {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        var gapsInRow = 0
        
        while true {
            let entry = activities[checkDate]
            if entry?.status == .completed || entry?.status == .halfDay {
                streak += 1
                gapsInRow = 0
            } else {
                // Not done, rest day, etc. count as gap
                gapsInRow += 1
            }
            
            if gapsInRow > 2 { // Break if gap is more than 2 days
                break
            }
            
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            
            // Limit search
            if let diff = calendar.dateComponents([.day], from: checkDate, to: Date()).day, diff > 400 {
                break
            }
        }
        
        self.currentStreak = streak
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }
}
