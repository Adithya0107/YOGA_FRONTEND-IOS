import Foundation
import SwiftUI
import Combine

// MARK: - Data Models
struct ZenProgress: Codable {
    var level: Int
    var streak_days: Int
    var total_minutes: Int
    var sessions: Int
    var bmi: Double
    var health_status: String
    var recovery_rate: Int
}

struct ZenActivity: Codable, Identifiable {
    var id: String { date }
    var date: String
    var minutes: Int
    var status: String // "done" | "missed"
}

struct ZenJourneyShot: Codable, Identifiable {
    var id: Int
    var image_path: String
    var age: Int
    var weight: Int
    var height: Int
    var bmi: Double
    var status: String
    var created_at: String
}

// MARK: - ZenAPI Service
class ZenAPIService: ObservableObject {
    static let shared = ZenAPIService()

    @Published var progress: ZenProgress = ZenProgress(
        level: 1, streak_days: 0, total_minutes: 0,
        sessions: 0, bmi: 0, health_status: "Normal", recovery_rate: 80
    )
    @Published var activities: [ZenActivity] = []
    @Published var journeyShots: [ZenJourneyShot] = []
    @Published var dailyPlan: [[String: Any]] = [] 
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private var userId: Int {
        UserDefaults.standard.integer(forKey: "user_id") > 0
            ? UserDefaults.standard.integer(forKey: "user_id") : 1
    }

    // MARK: - Fetch All Progress Data
    func fetchAll() {
        fetchProgress()
        fetchActivity()
        fetchJourneyHistory()
        fetchPlan()
    }

    func fetchPlan() {
        guard let url = URL(string: "\(AppTheme.baseURL)/plan/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { return }
                if let decoded = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    self?.dailyPlan = decoded
                }
            }
        }.resume()
    }

    func fetchProgress() {
        guard let url = URL(string: "\(AppTheme.baseURL)/get_stats/\(userId)") else { return }
        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else {
                    self?.errorMessage = error?.localizedDescription
                    return
                }
                if let decoded = try? JSONDecoder().decode(ZenProgress.self, from: data) {
                    self?.progress = decoded
                }
            }
        }.resume()
    }

    func fetchActivity() {
        guard let url = URL(string: "\(AppTheme.baseURL)/get_activity/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { return }
                if let decoded = try? JSONDecoder().decode([ZenActivity].self, from: data) {
                    self?.activities = decoded
                }
            }
        }.resume()
    }

    func fetchJourneyHistory() {
        guard let url = URL(string: "\(AppTheme.baseURL)/get_progress/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { return }
                if let decoded = try? JSONDecoder().decode([ZenJourneyShot].self, from: data) {
                    self?.journeyShots = decoded
                }
            }
        }.resume()
    }

    // MARK: - Save Daily Activity (Deprecated in favor of ActivityManager sync)
    func saveActivity(date: String, minutes: Int, status: String, completion: ((Bool) -> Void)? = nil) {
        // We now use ActivityManager for this, but keeping for compatibility
        completion?(true)
    }

    // MARK: - Upload Journey Shot
    func uploadJourneyShot(imageData: Data, age: Int, weight: Int, height: Int, status: String, completion: @escaping (Bool) -> Void) {
        guard let uploadUrl = URL(string: "\(AppTheme.baseURL)/upload_image") else { return }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"shot.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: body) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let imagePath = json["image_path"] as? String {
                
                // Now save progress record
                self?.saveProgressRecord(imagePath: imagePath, age: age, weight: weight, height: height, status: status, completion: completion)
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }

    private func saveProgressRecord(imagePath: String, age: Int, weight: Int, height: Int, status: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(AppTheme.baseURL)/add_progress") else { return }
        let body: [String: Any] = [
            "user_id": userId,
            "progress": [
                "age": "\(age)",
                "weight": "\(weight)",
                "height": "\(height)",
                "health_status": status,
                "image_path": imagePath
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            DispatchQueue.main.async {
                let success = error == nil
                if success { self?.fetchAll() }
                completion(success)
            }
        }.resume()
    }

    // MARK: - Save Changes (Age/Weight/Height)
    func saveChanges(age: Int, weight: Int, height: Int, completion: @escaping (Bool, ZenProgress?) -> Void) {
        // Reuse add_progress for basic changes or use update_profile
        completion(true, self.progress)
    }

    // MARK: - AI Coach Message
    func aiCoachMessage(name: String, streak: Int) -> String {
        switch streak {
        case 0:
            return "Welcome, \(name)! Every Zen Master began with a single breath. Today is Day 1 of your transformation. Let's start strong! 🌱"
        case 1...6:
            return "You're glowing, \(name)! \(streak) days in and your momentum is building. Keep showing up — the magic starts here! ✨"
        case 7...29:
            return "Incredible, \(name)! \(streak)-day streak — you've crossed the habit formation threshold. Your body is adapting and growing stronger every session. 💪"
        case 30...59:
            return "Strength Mastery unlocked, \(name)! \(streak) days of pure dedication. You are no longer just practicing yoga — you are living it! 🔥"
        case 60...149:
            return "Elite Performance mode, \(name)! \(streak) days! You are in the top 1% of practitioners. Your discipline is extraordinary! 🏆"
        default:
            return "ZEN MASTER status achieved, \(name)! \(streak) days of unwavering practice. You are the embodiment of peace, strength, and mastery! 🧘‍♂️✨"
        }
    }
}
