import SwiftUI

struct AppTheme {
    static let primaryPurple = Color(red: 108/255, green: 71/255, blue: 255/255)
    static let baseURL = "http://172.23.51.51:5001/user"
    static let yogaBaseURL = "http://172.23.51.51:5001/yoga"
    static let accentPurple = Color(red: 140/255, green: 100/255, blue: 255/255)
    static let lightLavender = Color(red: 250/255, green: 247/255, blue: 255/255)
    
    // Colors
    static let backgroundColor = Color(red: 245/255, green: 245/255, blue: 248/255)
    
    static var neumorphicBackground: Color {
        backgroundColor
    }
    
    static let cardBackground = Color.white
    
    static let textColor = Color(red: 26/255, green: 32/255, blue: 44/255)
    
    static var secondaryTextColor: Color {
        .gray
    }

    static let neumorphicShadowDark = Color(red: 163/255, green: 177/255, blue: 198/255).opacity(0.5)
    static let neumorphicShadowLight = Color.white
    
    static let purpleGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 130/255, green: 90/255, blue: 255/255),
            Color(red: 108/255, green: 71/255, blue: 255/255)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let authGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 140/255, green: 100/255, blue: 255/255), // Purple
            Color(red: 65/255, green: 182/255, blue: 255/255)   // Blue
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let minimalBackground = Color.white
    
    static func titleFont(size: CGFloat = 34) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func bodyFont(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}
