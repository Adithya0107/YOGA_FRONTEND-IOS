import SwiftUI

struct ProfileDetailView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userFullName") private var fullName = "Alex"
    @AppStorage("userGoal") private var goal = "Fat loss + Core strength"
    @AppStorage("userExperience") private var level = "Beginner"
    @AppStorage("userAge") private var age = "18-24"
    @AppStorage("userWorkoutPreference") private var workoutPreference = "Morning"
    @AppStorage("yogaChallengeMonths") private var challengeMonths: Int = 6
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            // Unlocked detail
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // User Info
                    VStack(spacing: 0) {
                        DetailRow(icon: "person.fill", label: "Name", value: fullName)
                        Divider().padding(.leading, 56)
                        DetailRow(icon: "calendar", label: "Age Group", value: age)
                    }
                    .background(AppTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                    .padding(.horizontal, 20)
                    
                    // Goals
                    VStack(spacing: 0) {
                        HStack(spacing: 14) {
                            Image(systemName: "target")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                                .frame(width: 32)
                            Text("Goal")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            Spacer()
                            Picker("", selection: $goal) {
                                Text("Lose Weight").tag("Lose Weight")
                                Text("Gain Muscle").tag("Gain Muscle")
                                Text("Flexibility").tag("Flexibility")
                                Text("Stress Relief").tag("Stress Relief")
                            }
                            .tint(.gray)
                            .onChange(of: goal) { _ in syncProfileWithBackend() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider().padding(.leading, 56)
                        
                        HStack(spacing: 14) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.primaryPurple)
                                .frame(width: 32)
                            Text("Level")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            Spacer()
                            Picker("", selection: $level) {
                                Text("Beginner").tag("Beginner")
                                Text("Intermediate").tag("Intermediate")
                                Text("Advanced").tag("Advanced")
                                Text("All").tag("All")
                            }
                            .tint(.gray)
                            .onChange(of: level) { _ in syncProfileWithBackend() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider().padding(.leading, 56)
                        
                        HStack(spacing: 14) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 251/255, green: 146/255, blue: 60/255))
                                .frame(width: 32)
                            Text("Time")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            Spacer()
                            Picker("", selection: $workoutPreference) {
                                Text("Morning").tag("Morning")
                                Text("Evening").tag("Evening")
                            }
                            .tint(.gray)
                            .onChange(of: workoutPreference) { _ in syncProfileWithBackend() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider().padding(.leading, 56)
                        
                        HStack(spacing: 14) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 34/255, green: 197/255, blue: 94/255))
                                .frame(width: 32)
                            Text("Yoga Challenge")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            Spacer()
                            Picker("", selection: $challengeMonths) {
                                Text("3 Months").tag(3)
                                Text("6 Months").tag(6)
                                Text("8 Months").tag(8)
                                Text("12 Months").tag(12)
                            }
                            .tint(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(AppTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
                    .padding(.horizontal, 20)
                    
                    // Stats
                    HStack(spacing: 14) {
                        MiniStatCard(value: "\(ActivityManager.shared.currentStreak)", label: "Streak", icon: "flame.fill", color: Color(red: 251/255, green: 146/255, blue: 60/255))
                        MiniStatCard(value: "\(ActivityManager.shared.totalPracticeMinutes)", label: "Minutes", icon: "clock.fill", color: AppTheme.primaryPurple)
                        MiniStatCard(value: "\(ActivityManager.shared.proLevel)", label: "Level", icon: "star.fill", color: Color(red: 234/255, green: 179/255, blue: 8/255))
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Profile Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func syncProfileWithBackend() {
        guard let url = URL(string: "\(AppTheme.baseURL)/update_profile") else { return }
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        
        let profileData: [String: Any] = [
            "goal": goal,
            "experience": level,
            "frequency": workoutPreference,
            "age": age,
            "gender": UserDefaults.standard.string(forKey: "userGender") ?? "",
            "height": UserDefaults.standard.string(forKey: "userHeight") ?? "",
            "weight": UserDefaults.standard.string(forKey: "userWeight") ?? ""
        ]
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "profile": profileData
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            // Refresh plan after profile update
            DispatchQueue.main.async {
                ZenAPIService.shared.fetchPlan()
            }
        }.resume()
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.primaryPurple)
                .frame(width: 32)
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

struct MiniStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
            }
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray.opacity(0.6))
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
    }
}
