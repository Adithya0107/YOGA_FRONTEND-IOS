//
//  ContentView.swift
//  yoga
//
//  Created by Aditya on 24/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isOnboardingActive = false
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("hasAccount") private var hasAccount = false
    
    var body: some View {
        ZStack {
            // Stable global background
            AppTheme.neumorphicBackground
                .ignoresSafeArea()
            
            Group {
                if !isOnboardingActive {
                    SplashScreenView()
                        .transition(.opacity)
                } else if !isAuthenticated {
                    WelcomeScreenView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    MainTabView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isOnboardingActive)
        .animation(.easeInOut(duration: 0.55), value: isAuthenticated)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isOnboardingActive = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
