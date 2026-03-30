import SwiftUI

struct PerformanceBarGraph: View {
    @ObservedObject private var activityManager = ActivityManager.shared
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.02), radius: 15, y: 10)

            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<7, id: \.self) { i in
                        let date = calendar.date(byAdding: .day, value: -(6 - i), to: Date())!
                        let startOfDay = calendar.startOfDay(for: date)
                        
                        // Sum calories from all session records on this day
                        let dayCalories = activityManager.sessionRecords
                            .filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
                            .reduce(0) { $0 + $1.caloriesBurned }
                        
                        let maxCalories: Double = 500 // 500 kcal goal for normalization
                        let height = max(4, min(140, Double(dayCalories) / maxCalories * 140))
                        let hasData = dayCalories > 0

                        VStack(spacing: 8) {
                            Text("\(dayCalories)")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(hasData ? AppTheme.primaryPurple : .clear)
                                .frame(height: 12)

                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.05))
                                    .frame(width: 32, height: 140)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: hasData
                                                ? [AppTheme.primaryPurple, Color(red: 170/255, green: 130/255, blue: 255/255)]
                                                : [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 32, height: CGFloat(height))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: height)
                            }

                            Text(getDayName(date: date))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 250)
    }

    private func getDayName(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
