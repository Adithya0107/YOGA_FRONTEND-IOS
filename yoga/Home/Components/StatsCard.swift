import SwiftUI

struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.gray.opacity(0.4))
                    .kerning(0.5)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            Spacer()
        }
        .padding(18)
        .glassCard(cornerRadius: 24)
    }
}
