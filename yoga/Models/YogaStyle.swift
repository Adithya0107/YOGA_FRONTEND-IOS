import SwiftUI

enum YogaLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case proAdvanced = "Pro Advanced"
    
    var minPracticeTime: Int { // in seconds
        switch self {
        case .beginner: return 10 * 60
        case .intermediate: return 20 * 60
        case .advanced: return 30 * 60
        case .proAdvanced: return 45 * 60
        }
    }
}

struct YogaStyle: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let level: YogaLevel
    let bgColor: Color
    let imageName: String
    let poses: [YogaPose]
    var videoURL: String? = nil
    var totalDuration: Int { // in seconds
        poses.reduce(0) { $0 + $1.duration }
    }
}
