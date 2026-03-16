import SwiftUI

// REFACTORED MAIN TAB VIEW
// All components moved to respective files in yoga/Body/, yoga/Explore/, etc.

struct MainTabView: View {
    @State private var selectedTab = 0
    // We no longer need manual history for root-level tab switching in a standard TabView architecture
    
    init() {
        // Fully hide and clear native tab bar elements to prevent "double bar" or background artifacts
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // HOME TAB
            NavigationStack {
                HomeDashboardView(selectedTab: $selectedTab)
                    .navigationBarHidden(true)
            }
            .tabItem { EmptyView() }
            .tag(0)
            
            // EXPLORE TAB
            NavigationStack {
                ExploreView()
                    .navigationBarHidden(true)
            }
            .tabItem { EmptyView() }
            .tag(1)
            
            // AI COACH TAB
            NavigationStack {
                AICoachView(selectedTab: $selectedTab)
                    .navigationBarHidden(true)
            }
            .tabItem { EmptyView() }
            .tag(2)
            
            // PROGRESS TAB
            NavigationStack {
                ProgressViewTab()
                    .navigationBarHidden(true)
            }
            .tabItem { EmptyView() }
            .tag(3)
            
            // PROFILE TAB
            NavigationStack {
                ProfileView()
                    .navigationBarHidden(true)
            }
            .tabItem { EmptyView() }
            .tag(4)
        }
        // safeAreaInset reserves exact space for the bar — no overlaps possible.
        // The VStack padding inside ensures the bar floats above the home indicator.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if selectedTab != 2 {
                VStack(spacing: 0) {
                    CustomTabBar(selectedTab: $selectedTab)
                        .padding(.bottom, 8)
                }
                .ignoresSafeArea(.keyboard)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    MainTabView()
}