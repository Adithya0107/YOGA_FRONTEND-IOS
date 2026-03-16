import SwiftUI

struct AIPersonalizedCard: View {
    @AppStorage("userFullName") private var fullName = "Alex"
    @ObservedObject private var zenAPI = ZenAPIService.shared

    private var firstName: String {
        String(fullName.split(separator: " ").first ?? "Friend")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [AppTheme.primaryPurple, Color(red: 170/255, green: 130/255, blue: 255/255)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 45, height: 45)
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI ZEN COACH")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(AppTheme.primaryPurple)
                        .kerning(1.5)
                    Text("Personalized Insight")
                        .font(.system(size: 14, weight: .bold))
                }

                Spacer()

                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(zenAPI.progress.streak_days)d")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            }

            Text(zenAPI.aiCoachMessage(name: firstName, streak: zenAPI.progress.streak_days))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 60/255, green: 70/255, blue: 90/255))
                .lineSpacing(4)
        }
        .padding(25)
        .background(
            ZStack {
                Color.white
                LinearGradient(
                    colors: [AppTheme.primaryPurple.opacity(0.08), Color.white],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(30)
        .padding(.horizontal, 24)
        .shadow(color: AppTheme.primaryPurple.opacity(0.05), radius: 15, x: 0, y: 10)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(AppTheme.primaryPurple.opacity(0.1), lineWidth: 1))
    }
}
