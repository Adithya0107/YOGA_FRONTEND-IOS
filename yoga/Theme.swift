import SwiftUI

struct AppTheme {
    static let primaryPurple = Color(red: 108/255, green: 71/255, blue: 255/255)
    static let baseURL = "http://Adityas-MacBook-Air.local:5001/user"
    static let yogaBaseURL = "http://Adityas-MacBook-Air.local:5001/yoga"
    static let accentPurple = Color(red: 140/255, green: 100/255, blue: 255/255)
    static let lightLavender = Color(red: 250/255, green: 247/255, blue: 255/255)
    
    // Colors
    static let backgroundColor = Color(red: 245/255, green: 245/255, blue: 247/255)
    
    static var neumorphicBackground: Color {
        backgroundColor
    }
    
    static let cardBackground = Color.white.opacity(0.6)
    
    static let textColor = Color(red: 26/255, green: 32/255, blue: 44/255)
    
    static var secondaryTextColor: Color {
        .gray
    }

    static let neumorphicShadowDark = Color.black.opacity(0.05)
    static let neumorphicShadowLight = Color.white.opacity(0.5)
    
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

extension View {
    func glassCard(cornerRadius: CGFloat = 40) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.4))
                    .background(
                        Blur(style: .systemUltraThinMaterialLight) 
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 30, x: 0, y: 20)
    }
}

struct ZenBackgroundView: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            // Soft Zen Blobs (Purple & Cyan Accents)
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(Color(red: 140/255, green: 100/255, blue: 255/255).opacity(0.15))
                        .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                        .blur(radius: 80)
                        .offset(x: -geo.size.width * 0.4, y: -geo.size.height * 0.2)
                    
                    Circle()
                        .fill(Color(red: 65/255, green: 182/255, blue: 255/255).opacity(0.12))
                        .frame(width: geo.size.width, height: geo.size.width)
                        .blur(radius: 90)
                        .offset(x: geo.size.width * 0.3, y: geo.size.height * 0.3)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// Helper for blur on older iOS if needed, but modern SwiftUI can use .background(.ultraThinMaterial)
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
