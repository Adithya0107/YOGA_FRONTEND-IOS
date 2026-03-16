import SwiftUI

// MARK: - Edit Profile

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userFullName") private var name = "Alex Johnson"
    @AppStorage("userBio") private var bio = "Zen Enthusiast"
    @AppStorage("userEmail") private var email = "alex@example.com"
    @AppStorage("userPhoneNumber") private var phoneNumber = ""
    @State private var showSaved = false
    @State private var isLoading = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Profile photo area
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [AppTheme.primaryPurple.opacity(0.2), AppTheme.primaryPurple.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 90, height: 90)
                        Image(systemName: "person.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                    Text("Tap to change photo")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.primaryPurple)
                }
                .padding(.top, 16)
                
                // Fields
                VStack(spacing: 0) {
                    SettingsTextField(label: "Full Name", text: $name, icon: "person")
                    Divider().padding(.leading, 56)
                    SettingsTextField(label: "Bio", text: $bio, icon: "text.quote")
                    Divider().padding(.leading, 56)
                    SettingsTextField(label: "Email", text: $email, icon: "envelope")
                    Divider().padding(.leading, 56)
                    SettingsTextField(label: "Phone Number", text: $phoneNumber, icon: "phone")
                }
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                
                // Save
                Button(action: {
                    saveProfile()
                }) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else if showSaved {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Saved!")
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(showSaved ? Color(red: 34/255, green: 197/255, blue: 94/255) : AppTheme.primaryPurple)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsTextField: View {
    let label: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.primaryPurple)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
                    .kerning(0.5)
                TextField(label, text: $text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textColor)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.cardBackground)
    }
}

extension EditProfileView {
    private func saveProfile() {
        guard let url = URL(string: "\(AppTheme.baseURL)/update_profile") else { return }
        
        // userId from AppStorage
        let userIdValue = UserDefaults.standard.integer(forKey: "userId")
        
        let profileData: [String: Any?] = [
            "name": name,
            "bio": bio,
            "email": email,
            "phone_number": phoneNumber,
            "age": UserDefaults.standard.string(forKey: "userAge"),
            "gender": UserDefaults.standard.string(forKey: "userGender"),
            "height": UserDefaults.standard.string(forKey: "userHeight"),
            "weight": UserDefaults.standard.string(forKey: "userWeight"),
            "goal": UserDefaults.standard.string(forKey: "userGoal"),
            "experience": UserDefaults.standard.string(forKey: "userExperience")
        ]
        
        let parameters: [String: Any] = [
            "user_id": userIdValue,
            "profile": profileData
        ]
        
        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if error == nil {
                    withAnimation(.spring(response: 0.4)) { showSaved = true }
                    ZenAPIService.shared.fetchPlan() // Refresh plan in case goal/level changed
                    AudioManager.shared.playSoundEffect(name: "success")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSaved = false
                        dismiss()
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Health Goals

struct HealthGoalsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("targetWeight") private var targetWeight = "70"
    @AppStorage("dailyGoalMinutes") private var dailyGoal = "30"
    @AppStorage("weeklyGoalSessions") private var weeklyGoal = "5"
    @State private var showSaved = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header card
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                    Text("Set goals to stay consistent")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                VStack(spacing: 0) {
                    GoalRow(icon: "scalemass.fill", label: "Target Weight (kg)", value: $targetWeight, color: Color(red: 239/255, green: 68/255, blue: 68/255))
                    Divider().padding(.leading, 56)
                    GoalRow(icon: "clock.fill", label: "Daily Goal (min)", value: $dailyGoal, color: AppTheme.primaryPurple)
                    Divider().padding(.leading, 56)
                    GoalRow(icon: "calendar.badge.clock", label: "Weekly Sessions", value: $weeklyGoal, color: Color(red: 34/255, green: 197/255, blue: 94/255))
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                
                Button(action: {
                    withAnimation(.spring(response: 0.4)) { showSaved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSaved = false
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        if showSaved {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Saved!")
                        } else {
                            Text("Save Goals")
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(showSaved ? Color(red: 34/255, green: 197/255, blue: 94/255) : AppTheme.primaryPurple)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Health Goals")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GoalRow: View {
    let icon: String
    let label: String
    @Binding var value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textColor)
            Spacer()
            TextField("", text: $value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .frame(width: 60)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.cardBackground)
    }
}

// MARK: - Notification Settings

struct NotificationSettingsView: View {
    @AppStorage("notif_dailyReminder") private var dailyReminders = true
    @AppStorage("notif_sessionComplete") private var sessionComplete = true
    @AppStorage("notif_streakWarning") private var streakWarning = true
    @AppStorage("notif_vibration") private var vibration = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 251/255, green: 146/255, blue: 60/255))
                    Text("Control your alert preferences")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                VStack(spacing: 0) {
                    NotifToggleRow(icon: "sun.max.fill", title: "Daily Reminder", subtitle: "Morning practice nudge", isOn: $dailyReminders, color: Color(red: 251/255, green: 146/255, blue: 60/255))
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "checkmark.circle.fill", title: "Session Complete", subtitle: "Post-practice summary", isOn: $sessionComplete, color: Color(red: 34/255, green: 197/255, blue: 94/255))
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "flame.fill", title: "Streak Warning", subtitle: "Don't lose your streak!", isOn: $streakWarning, color: Color(red: 239/255, green: 68/255, blue: 68/255))
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "iphone.radiowaves.left.and.right", title: "Vibration", subtitle: "Haptic feedback", isOn: $vibration, color: .gray)
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                .onChange(of: dailyReminders) { _ in AudioManager.shared.playClick() }
                .onChange(of: sessionComplete) { _ in AudioManager.shared.playClick() }
                .onChange(of: streakWarning) { _ in AudioManager.shared.playClick() }
                .onChange(of: vibration) { _ in AudioManager.shared.playClick() }
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotifToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textColor)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.primaryPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onTapGesture {
            AudioManager.shared.playClick()
        }
    }
}

// MARK: - Appearance Settings

struct AppearanceSettingsView: View {
    @AppStorage("darkMode") private var darkMode = false
    @ObservedObject private var activityManager = ActivityManager.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 168/255, green: 85/255, blue: 247/255))
                    Text("Customize your experience")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        Image(systemName: "timer")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 168/255, green: 85/255, blue: 247/255))
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Screen Time")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                            Text("App usage duration")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(ActivityManager.shared.screenTimeMinutes) mins")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.secondaryTextColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sounds & Haptics

struct SoundSettingsView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 34/255, green: 197/255, blue: 94/255))
                    Text("Audio and haptic preferences")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                VStack(spacing: 0) {
                    NotifToggleRow(icon: "waveform", title: "Sound Effects", subtitle: "UI interaction sounds", isOn: $audioManager.soundEffectsEnabled, color: Color(red: 34/255, green: 197/255, blue: 94/255))
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "bell.fill", title: "Timer Chime", subtitle: "Pose change alert", isOn: $audioManager.timerChimeEnabled, color: Color(red: 251/255, green: 146/255, blue: 60/255))
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "music.note", title: "Background Music", subtitle: "Ambient meditation sounds", isOn: $audioManager.bgMusicEnabled, color: AppTheme.primaryPurple)
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                .onChange(of: audioManager.soundEffectsEnabled) { _ in audioManager.playClick() }
            }
        }

        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Sounds & Haptics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Security & Privacy

struct SecurityPrivacyView: View {
    @AppStorage("dataSharing") private var dataSharing = false
    @AppStorage("analytics") private var analytics = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 14/255, green: 165/255, blue: 233/255))
                    Text("Protect your data")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                VStack(spacing: 0) {
                    NavigationLink(destination: ChangePasswordView()) {
                        HStack(spacing: 14) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 14/255, green: 165/255, blue: 233/255))
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Change Password")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.textColor)
                                Text("Update your account password")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.secondaryTextColor)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "hand.raised.fill", title: "Data Sharing", subtitle: "Share anonymous usage data", isOn: $dataSharing, color: Color(red: 239/255, green: 68/255, blue: 68/255))
                    Divider().padding(.leading, 56)
                    NotifToggleRow(icon: "chart.bar.fill", title: "Analytics", subtitle: "Help us improve the app", isOn: $analytics, color: Color(red: 34/255, green: 197/255, blue: 94/255))
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Security & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Change Password
struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userId") private var userId: Int = -1
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var message = ""
    @State private var isError = false
    @State private var isOldPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    HStack {
                        if isOldPasswordVisible {
                            TextField("Current Password", text: $oldPassword)
                        } else {
                            SecureField("Current Password", text: $oldPassword)
                        }
                        Button(action: { isOldPasswordVisible.toggle() }) {
                            Image(systemName: isOldPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .foregroundColor(AppTheme.textColor)
                    .background(AppTheme.cardBackground)
                    
                    Divider()
                    
                    HStack {
                        if isNewPasswordVisible {
                            TextField("New Password", text: $newPassword)
                        } else {
                            SecureField("New Password", text: $newPassword)
                        }
                        Button(action: { isNewPasswordVisible.toggle() }) {
                            Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .foregroundColor(AppTheme.textColor)
                    .background(AppTheme.cardBackground)
                    
                    Divider()
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            TextField("Confirm New Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm New Password", text: $confirmPassword)
                        }
                        Button(action: { isConfirmPasswordVisible.toggle() }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .foregroundColor(AppTheme.textColor)
                    .background(AppTheme.cardBackground)
                }
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                if !message.isEmpty {
                    Text(message)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isError ? .red : .green)
                        .padding(.horizontal, 20)
                }
                
                Button(action: updatePassword) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Update Password")
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.primaryPurple)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .disabled(isLoading || oldPassword.isEmpty || newPassword.isEmpty || newPassword != confirmPassword)
                
                Spacer()
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func updatePassword() {
        guard let url = URL(string: "\(AppTheme.baseURL)/change_password") else { return }
        
        let body: [String: Any] = [
            "user_id": userId,
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        isLoading = true
        message = ""
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                    isError = true
                    return
                }
                
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        message = "Password updated successfully!"
                        isError = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    } else {
                        message = (json["message"] as? String) ?? "Failed to update"
                        isError = true
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Data Management

struct DataManagementView: View {
    @State private var showClearAlert = false
    @State private var cleared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "externaldrive.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.gray)
                    Text("Manage your local data")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                VStack(spacing: 0) {
                    Button(action: {}) {
                        HStack(spacing: 14) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.primaryPurple)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Data")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                                Text("Download your activity as JSON")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    
                    Divider().padding(.leading, 56)
                    
                    Button(action: { showClearAlert = true }) {
                        HStack(spacing: 14) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Clear All Data")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                                Text("Reset everything to default")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                
                if cleared {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 34/255, green: 197/255, blue: 94/255))
                        Text("All data cleared successfully")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 34/255, green: 197/255, blue: 94/255))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(Color(red: 245/255, green: 245/255, blue: 248/255).ignoresSafeArea())
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Data?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                withAnimation { cleared = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { cleared = false }
                }
            }
        } message: {
            Text("This will permanently delete all activity history, session records, and preferences. This cannot be undone.")
        }
    }
}

// MARK: - Help & Support

struct HelpSupportView: View {
    @State private var expandedFAQ: String? = nil
    @State private var query = ""
    @State private var showSubmitted = false
    
    let faqs: [(question: String, answer: String)] = [
        ("How do I change my yoga level?", "Go to Profile Details in Settings and use the Level picker to choose Beginner, Intermediate, or Advanced."),
        ("How are calories calculated?", "Calories are estimated based on your active practice time using approximate MET values for yoga."),
        ("What does 85% completion mean?", "You need to actively practice through at least 85% of the total video/pose duration for a session to count as Completed."),
        ("How do streaks work?", "Complete at least one full session per day to maintain your streak. Missing a day resets it to zero."),
        ("Can I edit past activity?", "Yes! Tap on any day in the Progress calendar to update its status manually.")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 99/255, green: 102/255, blue: 241/255))
                    Text("Frequently asked questions")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                
                // FAQs
                VStack(spacing: 0) {
                    ForEach(faqs, id: \.question) { faq in
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    expandedFAQ = expandedFAQ == faq.question ? nil : faq.question
                                }
                            }) {
                                HStack {
                                    Text(faq.question)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: expandedFAQ == faq.question ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            
                            if expandedFAQ == faq.question {
                                Text(faq.answer)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 14)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            if faq.question != faqs.last?.question {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                
                // Contact support
                VStack(alignment: .leading, spacing: 12) {
                    Text("CONTACT SUPPORT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray.opacity(0.6))
                        .kerning(1)
                        .padding(.horizontal, 28)
                    
                    VStack(spacing: 0) {
                        TextField("Describe your issue...", text: $query, axis: .vertical)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(3...6)
                            .padding(16)
                        
                        Divider()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) { showSubmitted = true }
                            query = ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showSubmitted = false }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showSubmitted ? "checkmark.circle.fill" : "paperplane.fill")
                                    .font(.system(size: 14))
                                Text(showSubmitted ? "Submitted!" : "Submit")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(showSubmitted ? Color(red: 34/255, green: 197/255, blue: 94/255) : AppTheme.primaryPurple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .disabled(query.isEmpty && !showSubmitted)
                    }
                    .background(AppTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                    .padding(.horizontal, 20)
                }
                
                Spacer().frame(height: 40)
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Rate App

struct RateAppView: View {
    @Environment(\.dismiss) var dismiss
    @State private var rating = 0
    @State private var feedback = ""
    @State private var showSubmitted = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(Color(red: 234/255, green: 179/255, blue: 8/255))
                    Text("Enjoying the app?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textColor)
                    Text("Your feedback helps us improve")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
                .padding(.top, 28)
                
                // Stars
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(star <= rating ? Color(red: 234/255, green: 179/255, blue: 8/255) : Color.gray.opacity(0.3))
                            .scaleEffect(star <= rating ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: rating)
                            .onTapGesture { 
                                rating = star 
                                AudioManager.shared.playClick()
                            }
                    }
                }
                .padding(.vertical, 8)
                
                if rating > 0 {
                    Text(ratingLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.primaryPurple)
                        .transition(.opacity)
                }
                
                // Feedback
                VStack(spacing: 0) {
                    TextField("Share your thoughts (optional)...", text: $feedback, axis: .vertical)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(3...6)
                        .padding(16)
                        .foregroundColor(AppTheme.textColor)
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                
                // Submit
                Button(action: {
                    withAnimation(.spring(response: 0.4)) { showSubmitted = true }
                    AudioManager.shared.playSoundEffect(name: "success")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSubmitted = false
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        if showSubmitted {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Thank You!")
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Review")
                        }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        (rating > 0 && !showSubmitted)
                            ? AppTheme.primaryPurple
                            : (showSubmitted ? Color(red: 34/255, green: 197/255, blue: 94/255) : Color.gray.opacity(0.3))
                    )
                    .cornerRadius(16)
                }
                .disabled(rating == 0)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Rate the App")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var ratingLabel: String {
        switch rating {
        case 1: return "We can do better 😔"
        case 2: return "Needs improvement 🙁"
        case 3: return "It's okay 😊"
        case 4: return "Really good! 😄"
        case 5: return "We love you too! 🤩"
        default: return ""
        }
    }
}

// MARK: - About

struct AboutAppView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(LinearGradient(
                                colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        Image(systemName: "figure.yoga")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("Yoga Fitness Tracker")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                    Text("Version 1.0.0 (Build 1)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 28)
                
                VStack(spacing: 0) {
                    AboutRow(label: "Developer", value: "Aditya")
                    Divider().padding(.leading, 16)
                    AboutRow(label: "Platform", value: "iOS 16+")
                    Divider().padding(.leading, 16)
                    AboutRow(label: "Framework", value: "SwiftUI")
                    Divider().padding(.leading, 16)
                    AboutRow(label: "License", value: "Private")
                }
                .background(AppTheme.cardBackground)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                .padding(.horizontal, 20)
                
                Text("Made with 💜 for wellness")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryTextColor)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
