import SwiftUI

struct AISmartPlanCard: View {
    @Binding var selectedTab: Int
    @AppStorage("userFullName") private var fullName = "Alex"
    @AppStorage("userGoal") private var goal = "Fat loss + Core strength"
    @AppStorage("userExperience") private var experience = "Beginner"
    
    var planName: String {
        switch experience {
        case "Beginner": return "Start from Beginning"
        case "Intermediate": return "Start from Intermediate"
        case "Advanced": return "Start from Advanced"
        case "All": return "Start All Levels"
        default: return "Start from Beginning"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(planName)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Optimized for \(goal.lowercased())")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    selectedTab = 1 // Styles/Explore is 1
                }
            }) {
                Text("Start Workout")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            }
        }
        .padding(26)
        .background(
            LinearGradient(
                colors: [AppTheme.primaryPurple, Color(red: 65/255, green: 182/255, blue: 255/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(30)
        .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}
