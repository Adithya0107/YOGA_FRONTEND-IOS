import SwiftUI

struct RecentActivityBar: View {
    @ObservedObject private var zenAPI = ZenAPIService.shared
    private let calendar = Calendar.current

    // Build a lookup dict: "yyyy-MM-dd" -> ZenActivity
    private var activityDict: [String: ZenActivity] {
        Dictionary(uniqueKeysWithValues: zenAPI.activities.map { ($0.date, $0) })
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<14, id: \.self) { i in
                    let date = calendar.date(byAdding: .day, value: -(13 - i), to: Date())!
                    let key  = dateFormatter.string(from: date)
                    let entry = activityDict[key]

                    VStack(spacing: 12) {
                        Text(date.formatted(.dateTime.day()))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray.opacity(0.6))

                        ZStack {
                            if let activity = entry {
                                Circle()
                                    .fill(activity.status == "done"
                                          ? Color(red: 34/255, green: 197/255, blue: 94/255)
                                          : Color.red.opacity(0.8))
                                    .frame(width: 18, height: 18)

                                Image(systemName: activity.status == "done" ? "checkmark" : "xmark")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.12))
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                    .frame(minWidth: 34)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 4)
                    .background(calendar.isDateInToday(date)
                                ? AppTheme.primaryPurple.opacity(0.05)
                                : Color.white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(calendar.isDateInToday(date)
                                    ? AppTheme.primaryPurple.opacity(0.2)
                                    : Color.clear, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 2)
        }
    }
}
