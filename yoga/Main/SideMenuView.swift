import SwiftUI

struct SideMenuView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int
    @Binding var isPresented: Bool
    @AppStorage("userFullName") private var fullName = ""
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
    @State private var showSettings = false
    @State private var showRateUs = false
    @AppStorage("userAge") private var age = "Not Set"
    @AppStorage("userJoinDate") private var joinDate = "March 2024"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Color(red: 250/255, green: 250/255, blue: 252/255).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Back Button
                    Button(action: { 
                        isPresented = false
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .frame(width: 45, height: 45)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                            .padding(.leading, 24)
                            .padding(.top, 20)
                    }
                    
                    // Header Profile
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(AppTheme.primaryPurple)
                            .background(Color.white)
                            .clipShape(Circle())
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fullName.isEmpty ? "Alex" : fullName)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.primaryPurple)
                                
                                HStack(spacing: 12) {
                                    Label(age, systemImage: "calendar")
                                    Label(joinDate, systemImage: "door.left.hand.open")
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                selectedTab = 4 // Profile Tab
                                isPresented = false
                                dismiss()
                            }) {
                                Text("Edit")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.primaryPurple)
                            }
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // Menu Items
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            MenuButton(icon: "person.fill", title: "Profile") {
                                selectedTab = 4
                                isPresented = false
                                dismiss()
                            }
                            
                            MenuButton(icon: "star.fill", title: "Rate Us") {
                                showRateUs = true
                            }
                            
                            MenuButton(icon: "gearshape.fill", title: "Settings") {
                                selectedTab = 4 // Go to Profile as requested
                                isPresented = false
                                dismiss()
                            }
                            
                            MenuButton(icon: "square.and.arrow.up.fill", title: "Share App") {
                                shareApp()
                            }
                            
                            // Sign Out Menu Item
                            Button(action: {
                                isPresented = false
                                withAnimation {
                                    isAuthenticated = false
                                }
                                dismiss()
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 20))
                                        .frame(width: 30)
                                        .foregroundColor(.red)
                                    
                                    Text("Sign Out")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.75)
                .background(Color.white)
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showRateUs) {
            DummyDetailView(title: "Rate Us")
        }
        .onAppear {
            if UserDefaults.standard.string(forKey: "userJoinDate") == nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                joinDate = formatter.string(from: Date())
            }
        }
    }
    
    private func shareApp() {
        let text = "Check out this amazing Yoga Fitness App! 🧘‍♀️✨"
        let url = URL(string: "https://apps.apple.com/app/yoga-fitness")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
