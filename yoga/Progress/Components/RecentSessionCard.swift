import SwiftUI

struct RecentSessionCard: View {
    let xp: String
    
    var body: some View {
        HStack {
            Text(xp)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(AppTheme.primaryPurple)
            Spacer()
        }
        .padding()
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.05), lineWidth: 1))
    }
}
