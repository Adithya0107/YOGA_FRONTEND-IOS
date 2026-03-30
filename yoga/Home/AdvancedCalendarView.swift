import SwiftUI

struct AdvancedCalendarView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var activityManager = ActivityManager.shared
    @State private var selectedDate: Date?
    @State private var showEditSheet = false
    @AppStorage("yogaChallengeMonths") private var challengeMonths: Int = 6
    @AppStorage("userJoinDate") private var joinDateString: String = ""
    
    let calendar = Calendar.current
    
    private var challengeStartDate: Date {
        // Parse join date or use March 2026 as default
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        if let parsed = formatter.date(from: joinDateString) {
            return parsed
        }
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 3
        comps.day = 1
        return calendar.date(from: comps) ?? Date()
    }
    
    var months: [Date] {
        // Show exactly `challengeMonths` months starting from the challenge start date
        return (0..<challengeMonths).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: challengeStartDate)
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 250/255, blue: 252/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // HEADER
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black.opacity(0.8))
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    }
                    
                    Spacer()
                    
                    Text("Your Activity")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Spacer()
                    
                    // Invisible Spacer for alignment
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(months, id: \.self) { month in
                        VStack(alignment: .leading, spacing: 15) {
                            Text(month.formatted(.dateTime.month(.wide).year()))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .padding(.horizontal, 24)
                            
                            MonthGridView(month: month) { date in
                                selectedDate = date
                                showEditSheet = true
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                }
                .padding(.vertical, 20)
                
                // Navigation Link for Edit
                if let date = selectedDate {
                    NavigationLink(destination: DateEditSheet(date: date), isActive: $showEditSheet) { EmptyView() }
                }
            }
        }
    }
    .navigationBarHidden(true)
}
}


struct MonthGridView: View {
    let month: Date
    let onDateTap: (Date) -> Void
    @ObservedObject private var activityManager = ActivityManager.shared
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    private var days: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (weekday + 5) % 7 // Mon = 0
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<days.count, id: \.self) { index in
                if let date = days[index] {
                    let startOfDay = calendar.startOfDay(for: date)
                    let status = activityManager.activities[startOfDay]?.status
                    let computedStatus: ActivityStatus? = (status == nil && startOfDay < calendar.startOfDay(for: Date())) ? .notDone : status
                    
                    DateCell(date: date, status: computedStatus)
                        .onTapGesture {
                            onDateTap(date)
                        }
                } else {
                    Spacer().frame(height: 40)
                }
            }
        }
    }
}

struct DateCell: View {
    let date: Date
    let status: ActivityStatus?
    
    var body: some View {
        let isToday = Calendar.current.isDateInToday(date)
        let dayNum = Calendar.current.component(.day, from: date)
        
        ZStack {
            if isToday {
                Circle()
                    .fill(AppTheme.authGradient)
                    .frame(width: 36, height: 36)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 5, y: 2)
            } else if let status = status {
                switch status {
                case .completed:
                    Circle()
                        .fill(AppTheme.primaryPurple)
                        .frame(width: 32, height: 32)
                case .halfDay:
                    ZStack {
                        Circle()
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                            .frame(width: 32, height: 32)
                        SemiCircle()
                            .fill(Color.green)
                            .frame(width: 32, height: 32)
                    }
                case .notDone:
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                case .injury:
                    Circle()
                        .stroke(Color.red, lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                case .restDay:
                    Circle()
                        .fill(status.color)
                        .frame(width: 32, height: 32)
                }
            }
            
            Text("\(dayNum)")
                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                .foregroundColor(textColor(isToday: isToday))
        }
        .frame(height: 40)
    }
    
    private func textColor(isToday: Bool) -> Color {
        if isToday { return .white }
        if let status = status {
            if status == .completed { return .white }
            if status == .halfDay { return Color(red: 26/255, green: 32/255, blue: 44/255) }
            if status == .notDone { return .white }
            if status == .injury { return .red }
            if status == .restDay { return .white }
        }
        return Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.4)
    }
}
