import SwiftUI

struct LiquidHeaderView: View {
    let title: String
    var showMenuButton: Bool = false
    var menuAction: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if showMenuButton {
                Button(action: {
                    menuAction?()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Material.thinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.5), lineWidth: 1)
                        )
                }
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryPurple)
            
            Spacer()
            
            if showMenuButton {
                // Circular Placeholder for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Material.thinMaterial)
                .background(
                    LinearGradient(
                        colors: colorScheme == .dark 
                            ? [Color.black.opacity(0.1), Color.clear] 
                            : [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)
        )
        .overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3))
                    .frame(height: 1)
            }
        )
    }
}
