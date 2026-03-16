import Foundation

struct JourneyEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let weight: String
    let height: String
    let age: String?
    let healthStatus: String
    let imageData: Data?
}
