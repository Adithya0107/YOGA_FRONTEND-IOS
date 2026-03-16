import SwiftUI

struct PerformanceBarGraph: View {
    @ObservedObject private var zenAPI = ZenAPIService.shared
    private let calendar = Calendar.current

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var activityDict: [String: ZenActivity] {
        Dictionary(uniqueKeysWithValues: zenAPI.activities.map { ($0.date, $0) })
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.02), radius: 15, y: 10)

            VStack(spacing: 25) {
                HStack(alignment: .bottom, spacing: 15) { // Adjusted spacing for 6 items
                    ForEach(0..<6, id: \.self) { i in
                        let date = calendar.date(byAdding: .day, value: -(5 - i), to: Date())!
                        let key  = dateFormatter.string(from: date)
                        let entry = activityDict[key]
                        let minutes = Double(entry?.minutes ?? 0)
                        let maxMins: Double = 90  // normalize against 90 min max
                        let height = max(8, min(140, minutes / maxMins * 140))
                        let isDone = entry?.status == "done"

                        VStack(spacing: 12) {
                            // Minutes label on top of bar
                            if minutes > 0 {
                                Text("\(Int(minutes))")
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(AppTheme.primaryPurple)
                            }

                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.05))
                                    .frame(width: 32, height: 140)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: isDone
                                                ? [AppTheme.primaryPurple, Color(red: 170/255, green: 130/255, blue: 255/255)]
                                                : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
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
                .padding(.top, 20)
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
