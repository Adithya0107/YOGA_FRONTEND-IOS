import SwiftUI

struct SessionCompletionView: View {
    @Environment(\.dismiss) var dismiss
    let record: SessionRecord
    let onDone: () -> Void
    
    private var statusColor: Color {
        switch record.status {
        case .completed: return Color(red: 34/255, green: 197/255, blue: 94/255)
        case .partial: return Color(red: 234/255, green: 179/255, blue: 8/255)
        case .failed: return Color(red: 239/255, green: 68/255, blue: 68/255)
        }
    }
    
    private var statusIcon: String {
        switch record.status {
        case .completed: return "checkmark.seal.fill"
        case .partial: return "minus.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    private var motivationalMessage: String {
        switch record.status {
        case .completed:
            return "Outstanding work! You've completed this session in full. Your commitment is building real results!"
        case .partial:
            return "Good effort! You made solid progress. Keep showing up and you'll hit full completion next time."
        case .failed:
            return "Every journey starts with a step. Don't stop here — come back stronger tomorrow!"
        }
    }
    
    private func durationString(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if secs == 0 { return "\(mins) min" }
        return "\(mins) min \(secs) sec"
    }
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 250/255, blue: 252/255).ignoresSafeArea()
            
            // Ambient glow
            Circle()
                .fill(statusColor.opacity(0.1))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(y: -150)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Status Icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.08))
                        .frame(width: 130, height: 130)
                    Circle()
                        .fill(statusColor.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: statusIcon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(statusColor)
                }
                .padding(.bottom, 24)
                
                Text(record.status.rawValue.uppercased())
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(statusColor)
                    .kerning(2)
                
                Text("Session Summary")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                
                Text(record.styleName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.6))
                    .padding(.bottom, 32)
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    SummaryMetricTile(label: "Time Practiced", value: durationString(record.actualPracticeTime), icon: "clock.fill", color: Color(red: 65/255, green: 182/255, blue: 255/255))
                    SummaryMetricTile(label: "Completion", value: String(format: "%.0f%%", record.completionPercentage), icon: "chart.bar.fill", color: statusColor)
                    SummaryMetricTile(label: "Calories", value: "~\(record.caloriesBurned) kal", icon: "flame.fill", color: Color(red: 251/255, green: 146/255, blue: 60/255))
                    SummaryMetricTile(label: "Level", value: record.level.rawValue, icon: "crown.fill", color: Color(red: 167/255, green: 139/255, blue: 250/255))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                
                // Motivational message
                Text(motivationalMessage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                
                Spacer()
                
                // Done Button
                Button(action: {
                    onDone()
                    dismiss()
                }) {
                    Text("BACK TO EXPLORE")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
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
                .padding(.bottom, 50)
            }
        }
    }
}

struct SummaryMetricTile: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
            
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.3))
                .kerning(1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, y: 8)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.08), lineWidth: 1))
    }
}
