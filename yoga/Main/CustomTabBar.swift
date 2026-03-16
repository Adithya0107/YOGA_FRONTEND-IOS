import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation // For sliding indicator micro-animation
    
    let tabs = [
        ("house", "HOME"),
        ("safari", "STYLES"),
        ("message", "AI COACH"),
        ("chart.bar", "PROGRESS"),
        ("person", "PROFILE")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    if selectedTab != index {
                        // Smooth animated transition
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.5)) {
                            selectedTab = index
                        }
                    }
                }) {
                    ZStack {
                        // Sliding Indicator / Glass Bubble behind the active tab
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06))
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.05), lineWidth: 0.5)
                                )
                                // Subtle glow under the active tab bubble
                                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .matchedGeometryEffect(id: "TabIndicator", in: animation)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 6)
                        }
                        
                        VStack(spacing: 5) {
                            Image(systemName: selectedTab == index ? "\(tabs[index].0).fill" : tabs[index].0)
                                .font(.system(size: 22, weight: selectedTab == index ? .bold : .medium))
                                .foregroundColor(selectedTab == index ? (colorScheme == .dark ? .white : .black) : .gray.opacity(0.7))
                                // Micro-animation scaling
                                .scaleEffect(selectedTab == index ? 1.15 : 1.0)
                                // Add subtle glow to icon mostly visible in dark mode
                                .shadow(color: selectedTab == index && colorScheme == .dark ? Color.white.opacity(0.5) : Color.clear, radius: 4, x: 0, y: 1)
                            
                            Text(tabs[index].1)
                                .font(.system(size: 9, weight: selectedTab == index ? .black : .bold))
                                .kerning(0.5)
                                .foregroundColor(selectedTab == index ? (colorScheme == .dark ? .white : .black) : .gray.opacity(0.7))
                        }
                        .padding(.vertical, 12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Liquid Glass Body
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(Material.thinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 35, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: colorScheme == .dark
                                        ? [Color.white.opacity(0.12), Color.white.opacity(0.02)]
                                        : [Color.white.opacity(0.8), Color.white.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Inner highlight for liquid depth
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.35 : 0.6),
                                Color.white.opacity(0.1),
                                Color.black.opacity(colorScheme == .dark ? 0.15 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.12), radius: 25, x: 0, y: 12)
        )
        .frame(height: 70)
        .padding(.horizontal, 20)
        // No bottom padding here — safeAreaInset in MainTabView handles safe area correctly
    }
    
    private func getSafeAreaBottom() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let bottom = window.safeAreaInsets.bottom
            return bottom == 0 ? 10 : bottom // Slightly tighter for "down" look
        }
        return 10
    }
}
