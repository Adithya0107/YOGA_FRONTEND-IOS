import SwiftUI

struct ModernMetricCard: View {
    let title: String
    @Binding var value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .padding(8)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
                Spacer()
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.gray.opacity(0.5))
                    .kerning(1)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                TextField("0", text: $value)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255)) // Dark text color
                    .keyboardType(.numberPad)
                    .onChange(of: value) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered.count > 3 {
                            value = String(filtered.prefix(3))
                        } else {
                            value = filtered
                        }
                    }
                Text(unit)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.bottom, 6)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.gray.opacity(0.03), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.01), radius: 10, y: 5)
    }
}
