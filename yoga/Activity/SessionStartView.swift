import SwiftUI

struct SessionStartView: View {
    @Environment(\.dismiss) var dismiss
    let style: YogaStyle
    let onStart: () -> Void
    
    private func durationString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if secs == 0 { return "\(mins) min" }
        return "\(mins) min \(secs) sec"
    }
    
    private var levelColor: Color {
        switch style.level {
        case .beginner: return Color(red: 34/255, green: 197/255, blue: 94/255)
        case .intermediate: return Color(red: 234/255, green: 179/255, blue: 8/255)
        case .advanced: return Color(red: 239/255, green: 68/255, blue: 68/255)
        case .proAdvanced: return Color(red: 124/255, green: 58/255, blue: 237/255)
        }
    }
    
    private var levelIcon: String {
        switch style.level {
        case .beginner: return "leaf.fill"
        case .intermediate: return "flame.fill"
        case .advanced: return "bolt.fill"
        case .proAdvanced: return "crown.fill"
        }
    }
    
    var body: some View {
        ZStack {
            // Light Background
            Color(red: 250/255, green: 250/255, blue: 252/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top dismiss
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // Hero Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryPurple.opacity(0.08))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(AppTheme.primaryPurple.opacity(0.12))
                        .frame(width: 90, height: 90)
                    Image(systemName: levelIcon)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppTheme.primaryPurple)
                }
                .padding(.bottom, 30)
                
                // Style Name
                Text(style.name.uppercased())
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.6))
                    .kerning(2)
                
                Text("Session Ready")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                
                // Info Cards
                VStack(spacing: 12) {
                    SessionInfoRow(icon: "graduationcap.fill", label: "Level", value: style.level.rawValue, tint: levelColor)
                    SessionInfoRow(icon: "clock.fill", label: "Total Duration", value: durationString(style.totalDuration), tint: AppTheme.primaryPurple)
                    SessionInfoRow(icon: "checkmark.shield.fill", label: "Min Required Time", value: durationString(style.level.minPracticeTime), tint: Color(red: 251/255, green: 146/255, blue: 60/255))
                    SessionInfoRow(icon: "person.fill", label: "Poses", value: "\(style.poses.count) poses", tint: AppTheme.primaryPurple)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Rules Banner
                VStack(alignment: .leading, spacing: 12) {
                    Text("SESSION RULES")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.4))
                        .kerning(1.5)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        RuleRow(icon: "⏸", text: "App in background >60s pauses timer")
                        RuleRow(icon: "📵", text: "Skipping ahead is not counted")
                        RuleRow(icon: "✅", text: "Complete 85% of video to earn credit")
                    }
                }
                .padding(22)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 15, y: 8)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.08), lineWidth: 1))
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // Start Button
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onStart()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .black))
                        Text("START SESSION")
                            .font(.system(size: 16, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.primaryPurple, Color(red: 65/255, green: 182/255, blue: 255/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 20, y: 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct SessionInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.5))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray.opacity(0.05), lineWidth: 1))
    }
}

struct RuleRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.8))
        }
    }
}
