import SwiftUI

struct QuoteCard: View {
    var body: some View {
        ZStack {
            // Faint icon background
            HStack {
                Spacer()
                Image(systemName: "quote.closing")
                    .font(.system(size: 150))
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.05))
                    .rotationEffect(.degrees(10))
                    .offset(x: 20, y: -20)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 25) {
                Text("\"Your body can do anything.\nIt's your mind you have to\nconvince.\"")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .italic()
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                    .lineSpacing(4)
                
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(AppTheme.primaryPurple)
                        .frame(width: 40, height: 2)
                    
                    Text("ZEN CORE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(AppTheme.primaryPurple)
                        .kerning(1.5)
                }
            }
            .padding(30)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.02), radius: 15, y: 10)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.05), lineWidth: 1))
    }
}
