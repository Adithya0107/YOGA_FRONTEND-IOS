import SwiftUI

struct RecoveryGuidanceCard: View {
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 235/255, green: 250/255, blue: 255/255))
                    .frame(width: 65, height: 65)
                Image(systemName: "battery.100.bolt")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 65/255, green: 182/255, blue: 255/255))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("RECOVERY FOCUS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(red: 65/255, green: 182/255, blue: 255/255))
                        .kerning(1)
                    Spacer()
                    Text("ACTIVE REST")
                        .font(.system(size: 9, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 65/255, green: 182/255, blue: 255/255).opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text("Your body needs a low-impact day. We suggest a 'Restorative Flow' to maintain your streak without burnout.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.02), radius: 15, y: 10)
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.gray.opacity(0.05), lineWidth: 1))
    }
}
