import Foundation

struct SavedVideo: Codable, Identifiable {
    var id = UUID()
    var title: String
    var videoURL: String
    var instructor: String?
    var dateAdded: Date
}
