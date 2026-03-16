import SwiftUI

struct TaskItem: View {
    let title: String
    let time: String
    let icon: String
    let isCompleted: Bool
    let isOngoing: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCompleted ? AppTheme.primaryPurple : (isOngoing ? Color(red: 65/255, green: 182/255, blue: 255/255).opacity(0.1) : Color.gray.opacity(0.05)))
                    .frame(width: 45, height: 45)
                
                Image(systemName: isCompleted ? "chevron.down" : icon)
                    .font(.system(size: isCompleted ? 14 : 18, weight: .bold))
                    .foregroundColor(isCompleted ? .white : (isOngoing ? Color(red: 65/255, green: 182/255, blue: 255/255) : .gray.opacity(0.3)))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isCompleted ? .gray.opacity(0.3) : Color(red: 26/255, green: 32/255, blue: 44/255))
                    .strikethrough(isCompleted, color: .gray.opacity(0.2))
                
                Text(time)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isOngoing ? Color(red: 65/255, green: 182/255, blue: 255/255) : .gray.opacity(0.4))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(isCompleted ? AppTheme.primaryPurple : Color.gray.opacity(0.1))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 4)
    }
}
