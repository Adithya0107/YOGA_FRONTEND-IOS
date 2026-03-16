import SwiftUI

struct WelcomeScreenView: View {
    @State private var showAuth = false
    @State private var initialAuthStep: AuthStep = .personalizedForYou
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("hasAccount") private var hasAccount = false
    @State private var hasAutoRedirected = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Minimal Background
                AppTheme.minimalBackground
                    .ignoresSafeArea()
                
                AppTheme.lightLavender.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Small Logo - Exact Image Asset
                    LogoView(isLarge: false)
                    
                    Spacer()
                    
                    VStack(spacing: 48) {
                        // Headline & Description
                        VStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Begin Your")
                                    .font(AppTheme.titleFont(size: 40))
                                    .foregroundStyle(AppTheme.primaryPurple)
                                
                                Text("Evolution")
                                    .font(AppTheme.titleFont(size: 44))
                                    .foregroundStyle(AppTheme.primaryPurple)
                            }
                            
                            Text("AI-powered yoga routines personalized\nfor your unique body and goals.")
                                .font(AppTheme.bodyFont(size: 17))
                                .foregroundStyle(Color.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                        }
                        .padding(.horizontal, 40)
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            // Create Account Button
                            Button(action: { 
                                initialAuthStep = .personalizedForYou
                                showAuth = true 
                            }) {
                                Text("Create Account")
                                    .font(AppTheme.bodyFont(size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                                    .background(AppTheme.primaryPurple)
                                    .cornerRadius(20)
                                    .shadow(color: AppTheme.primaryPurple.opacity(0.15), radius: 10, y: 5)
                            }
                            
                            // Sign In Button
                            Button(action: { 
                                initialAuthStep = .signIn
                                showAuth = true 
                            }) {
                                Text("Sign In")
                                    .font(AppTheme.bodyFont(size: 18))
                                    .foregroundColor(AppTheme.primaryPurple)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(AppTheme.primaryPurple.opacity(0.15), lineWidth: 1.5)
                                    )
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $showAuth) {
                AuthenticationView(initialStep: initialAuthStep)
                    .navigationBarHidden(true)
            }
        }
        .onAppear {
            if hasAccount && !isAuthenticated && !hasAutoRedirected {
                initialAuthStep = .signIn
                showAuth = true
                // We keep it true so that if they click "X", they stay on Welcome screen
                hasAutoRedirected = true 
            }
        }
    }
}

#Preview {
    WelcomeScreenView()
}
