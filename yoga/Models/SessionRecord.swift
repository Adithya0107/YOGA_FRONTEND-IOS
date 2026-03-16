import Foundation

enum SessionStatus: String, Codable {
    case completed = "Completed"
    case partial = "Partially Completed"
    case failed = "Not Completed"
}

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let styleName: String
    let level: YogaLevel
    let totalVideoDuration: Int // seconds
    let actualPracticeTime: Int // seconds
    let completionPercentage: Double // 0.0 to 100.0
    let status: SessionStatus
    let caloriesBurned: Int
}
