import SwiftUI

struct SuggestionPill: View {
    let icon: String // SF Symbol
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
            
            Text(text)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                .kerning(1)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.05), lineWidth: 1))
    }
}
