import SwiftUI

struct ActivityStatCard: View {
    let icon: String // SF Symbol
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
                    .kerning(0.5)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 25)
    }
}
