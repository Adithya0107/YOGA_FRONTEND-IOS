import SwiftUI

struct SplashScreenView: View {
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            AppTheme.minimalBackground
                .ignoresSafeArea()
            
            AppTheme.lightLavender.opacity(0.3)
                .ignoresSafeArea()
            
            LogoView()
                .opacity(opacity)
                .scaleEffect(0.9 + (opacity * 0.1))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
