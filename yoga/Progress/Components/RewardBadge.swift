import SwiftUI

struct RewardBadge: View {
    let day: String
    let title: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppTheme.primaryPurple : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: isUnlocked ? "trophy.fill" : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? .white : .gray.opacity(0.4))
            }
            .shadow(color: isUnlocked ? AppTheme.primaryPurple.opacity(0.3) : Color.clear, radius: 8, y: 5)
            
            VStack(spacing: 2) {
                Text("\(day) DAYS")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(isUnlocked ? AppTheme.primaryPurple : .gray)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(isUnlocked ? AppTheme.primaryPurple.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1))
    }
}
