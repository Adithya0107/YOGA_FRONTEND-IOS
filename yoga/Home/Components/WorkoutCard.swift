import SwiftUI

struct WorkoutCard: View {
    var experienceLabel: String = "ADVANCED"
    var title: String = "Sun Salutation\nFlow Phase II"
    var description: String = "Deepen your practice with advanced flows."
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image/Color
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.9)) // Fallback if image not there
                .frame(height: 380)
                .overlay(
                    Image(systemName: "figure.yoga")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.1))
                        .padding(40)
                )
            
            // Linear Gradient
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(30)
            
            VStack(alignment: .leading, spacing: 15) {
                // Tags
                HStack(spacing: 8) {
                    Text(experienceLabel)
                        .font(.system(size: 9, weight: .black))
                        .kerning(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.primaryPurple)
                        .cornerRadius(20)
                }
                
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            .padding(30)
        }
    }
}
