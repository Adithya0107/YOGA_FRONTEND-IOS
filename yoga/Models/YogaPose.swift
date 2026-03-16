import SwiftUI

struct YogaPose: Identifiable {
    let id = UUID()
    let stepNumber: Int
    let title: String
    let description: String
    let iconName: String
    let duration: Int // in seconds
    var imageName: String? = nil
}
