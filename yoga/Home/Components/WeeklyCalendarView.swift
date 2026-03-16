import SwiftUI

struct WeeklyCalendarView: View {
    var onDayTap: (Date) -> Void
    @ObservedObject private var activityManager = ActivityManager.shared
    
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let delta = (weekday + 5) % 7 // Monday as 0
        let monday = calendar.date(byAdding: .day, value: -delta, to: today)!
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                let isToday = Calendar.current.isDateInToday(date)
                let dayNum = Calendar.current.component(.day, from: date)
                let weekdayIndex = (Calendar.current.component(.weekday, from: date) + 5) % 7
                let status = activityManager.activities[date]?.status
                
                VStack(spacing: 12) {
                    Text(days[weekdayIndex])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray.opacity(0.4))
                    
                    ZStack {
                        if isToday {
                            Circle()
                                .fill(AppTheme.authGradient)
                                .frame(width: 38, height: 38)
                                .shadow(color: AppTheme.primaryPurple.opacity(0.25), radius: 8, y: 4)
                            Text("\(dayNum)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        } else if let status = status {
                            if status == .completed {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 38, height: 38)
                                Text("\(dayNum)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            } else if status == .halfDay {
                                Circle()
                                    .trim(from: 0.0, to: 0.5)
                                    .fill(status.color)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 38, height: 38)
                                Text("\(dayNum)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(status.color)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 38, height: 38)
                                Text("\(dayNum)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(status.color)
                            }
                        } else {
                            Text("\(dayNum)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 38, height: 38)
                        }
                    }
                    .onTapGesture {
                        onDayTap(date)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.04), radius: 15, y: 5)
    }
}
