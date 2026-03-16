import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("profileImageData") private var profileImageData: Data = Data()
    @State private var selectedProfileItem: PhotosPickerItem? = nil
    @AppStorage("userFullName") private var fullName = "Alex Johnson"
    @AppStorage("userBio") private var bio = "Zen Enthusiast"
    @AppStorage("current_streak") private var currentStreak: Int = 0
    @AppStorage("total_practice_minutes") private var totalMinutes: Int = 0
    @AppStorage("isAuthenticated") private var isAuthenticated = true
    @AppStorage("user_id") private var savedUserId: Int = 0
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showDeleteErrorAlert = false
    @State private var deleteErrorMessage = ""
    @State private var isDeletingAccount = false
    
    var body: some View {
        ZStack {
            Color(red: 245/255, green: 245/255, blue: 248/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ─── HEADER Pinned ───
                LiquidHeaderView(title: "Settings")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                    
                    // ─── PROFILE CARD ───
                    NavigationLink(destination: EditProfileView()) {
                        HStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 130/255, green: 90/255, blue: 255/255),
                                                     Color(red: 90/255, green: 170/255, blue: 255/255)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                
                                if !profileImageData.isEmpty, let uiImage = UIImage(data: profileImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 26, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(fullName)
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.primaryPurple)
                                Text(bio)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(22)
                        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    // ─── STATS STRIP ───
                    HStack(spacing: 0) {
                        StatsPill(value: "\(currentStreak)", label: "Day Streak", icon: "flame.fill", color: Color(red: 251/255, green: 146/255, blue: 60/255))
                        
                        Rectangle().fill(Color.gray.opacity(0.15)).frame(width: 1, height: 36)
                        
                        StatsPill(value: "\(totalMinutes)", label: "Minutes", icon: "clock.fill", color: AppTheme.primaryPurple)
                        
                        Rectangle().fill(Color.gray.opacity(0.15)).frame(width: 1, height: 36)
                        
                        StatsPill(value: "\(ActivityManager.shared.proLevel)", label: "Level", icon: "star.fill", color: Color(red: 234/255, green: 179/255, blue: 8/255))
                    }
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // ─── SECTION: ACCOUNT ───
                    SettingsSectionHeader(title: "ACCOUNT")
                    
                    SettingsGroup {
                        NavigationLink(destination: EditProfileView()) {
                            SettingsRow(icon: "person.circle.fill", title: "Edit Profile", subtitle: "Name, photo, bio", tint: AppTheme.primaryPurple)
                        }
                        SettingsDivider()
                        NavigationLink(destination: HealthGoalsView()) {
                            SettingsRow(icon: "heart.circle.fill", title: "Health Goals", subtitle: "Weight, targets", tint: Color(red: 239/255, green: 68/255, blue: 68/255))
                        }
                        SettingsDivider()
                        NavigationLink(destination: ProfileDetailView()) {
                            SettingsRow(icon: "person.text.rectangle.fill", title: "Profile Details", subtitle: "Goals, preferences, stats", tint: Color(red: 59/255, green: 130/255, blue: 246/255))
                        }
                    }
                    
                    // ─── SECTION: PREFERENCES ───
                    SettingsSectionHeader(title: "PREFERENCES")
                    
                    SettingsGroup {
                        NavigationLink(destination: NotificationSettingsView()) {
                            SettingsRow(icon: "bell.badge.fill", title: "Notifications", subtitle: "Reminders, alerts", tint: Color(red: 251/255, green: 146/255, blue: 60/255))
                        }
                        SettingsDivider()
                        NavigationLink(destination: AppearanceSettingsView()) {
                            SettingsRow(icon: "paintbrush.fill", title: "Appearance", subtitle: "Theme, display", tint: Color(red: 168/255, green: 85/255, blue: 247/255))
                        }
                        SettingsDivider()
                        NavigationLink(destination: SoundSettingsView()) {
                            SettingsRow(icon: "speaker.wave.2.fill", title: "Sounds & Haptics", subtitle: "Audio feedback", tint: Color(red: 34/255, green: 197/255, blue: 94/255))
                        }
                    }
                    
                    // ─── SECTION: PRIVACY & SECURITY ───
                    SettingsSectionHeader(title: "PRIVACY & SECURITY")
                    
                    SettingsGroup {
                        NavigationLink(destination: SecurityPrivacyView()) {
                            SettingsRow(icon: "lock.shield.fill", title: "Security", subtitle: "Password, data access", tint: Color(red: 14/255, green: 165/255, blue: 233/255))
                        }
                        SettingsDivider()
                        NavigationLink(destination: DataManagementView()) {
                            SettingsRow(icon: "externaldrive.fill", title: "Data Management", subtitle: "Export, clear data", tint: Color(red: 107/255, green: 114/255, blue: 128/255))
                        }
                    }
                    
                    // ─── SECTION: SUPPORT ───
                    SettingsSectionHeader(title: "SUPPORT")
                    
                    SettingsGroup {
                        NavigationLink(destination: HelpSupportView()) {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & FAQ", subtitle: "Common questions", tint: Color(red: 99/255, green: 102/255, blue: 241/255))
                        }
                        SettingsDivider()
                        NavigationLink(destination: RateAppView()) {
                            SettingsRow(icon: "star.circle.fill", title: "Rate the App", subtitle: "Share your feedback", tint: Color(red: 234/255, green: 179/255, blue: 8/255))
                        }
                        SettingsDivider()
                        NavigationLink(destination: AboutAppView()) {
                            SettingsRow(icon: "info.circle.fill", title: "About", subtitle: "Version, licenses", tint: Color.gray)
                        }
                    }
                    
                    // ─── LOG OUT ───
                    Button(action: { showLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Log Out")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.08))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // ─── DELETE ACCOUNT ───
                    Button(action: { showDeleteAlert = true }) {
                        HStack(spacing: 8) {
                            if isDeletingAccount {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 153/255, green: 27/255, blue: 27/255)))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            Text(isDeletingAccount ? "Deleting..." : "Delete Account")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(Color(red: 153/255, green: 27/255, blue: 27/255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 254/255, green: 226/255, blue: 226/255))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 239/255, green: 68/255, blue: 68/255).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(isDeletingAccount)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Version tag
                    Text("Yoga Fitness Tracker v1.0.0")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                }
            }
        }
    }
    .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) { 
                isAuthenticated = false
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account Permanently?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Forever", role: .destructive) {
                performDeleteAccount()
            }
        } message: {
            Text("This will permanently delete your account, all sessions, and progress. This action cannot be undone.")
        }
        .alert("Deletion Failed", isPresented: $showDeleteErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deleteErrorMessage)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // ─── DELETE ACCOUNT FUNCTION ───
    private func performDeleteAccount() {
        guard savedUserId > 0 else {
            // No user id stored, just clear local state and log out
            clearAllLocalData()
            isAuthenticated = false
            return
        }
        
        isDeletingAccount = true
        
        guard let url = URL(string: "\(AppTheme.baseURL)/delete_account") else {
            isDeletingAccount = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["user_id": savedUserId])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isDeletingAccount = false
                
                if let error = error {
                    deleteErrorMessage = error.localizedDescription
                    showDeleteErrorAlert = true
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Success - clear all local data and log out
                    clearAllLocalData()
                    isAuthenticated = false
                } else {
                    // Parse error from response
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let msg = json["message"] as? String {
                        deleteErrorMessage = msg
                    } else {
                        deleteErrorMessage = "Failed to delete account. Please try again."
                    }
                    showDeleteErrorAlert = true
                }
            }
        }.resume()
    }
    
    private func clearAllLocalData() {
        // Clear all AppStorage keys related to the user session
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "userFullName")
        UserDefaults.standard.removeObject(forKey: "userBio")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "current_streak")
        UserDefaults.standard.removeObject(forKey: "total_practice_minutes")
        UserDefaults.standard.removeObject(forKey: "screen_time_minutes")
        UserDefaults.standard.removeObject(forKey: "session_records")
        UserDefaults.standard.removeObject(forKey: "user_activity_data")
        UserDefaults.standard.removeObject(forKey: "profileImageData")
    }
}

// MARK: - Reusable Settings Components

struct StatsPill: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
            }
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray.opacity(0.6))
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsSectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
                .kerning(1)
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}

struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
            .padding(.horizontal, 20)
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider().padding(.leading, 60)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(tint)
                .frame(width: 34, height: 34)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

// MARK: - Shared Components (kept for backward compat)

struct MilestoneRow: View {
    let title: String
    let xp: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(isCompleted ? AppTheme.primaryPurple : Color.gray.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(isCompleted ? AppTheme.primaryPurple : Color.clear))
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isCompleted ? .gray.opacity(0.4) : Color(red: 26/255, green: 32/255, blue: 44/255))
                    .strikethrough(isCompleted, color: .gray.opacity(0.4))
                Text(xp)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(Color(red: 65/255, green: 182/255, blue: 255/255))
            }
            Spacer()
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.01), radius: 5, y: 5)
    }
}


