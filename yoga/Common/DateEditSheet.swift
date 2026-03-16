import SwiftUI

struct DateEditSheet: View {
    @Environment(\.dismiss) var dismiss
    let date: Date
    @ObservedObject private var activityManager = ActivityManager.shared
    @State private var selectedStatus: ActivityStatus?
    @State private var note: String = ""
    
    init(date: Date) {
        self.date = date
        let existing = ActivityManager.shared.activities[Calendar.current.startOfDay(for: date)]
        _selectedStatus = State(initialValue: existing?.status)
        _note = State(initialValue: existing?.note ?? "")
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                    Text(date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .padding(.top, 20)
                    
                    VStack(spacing: 15) {
                        StatusRow(status: .completed, isSelected: selectedStatus == .completed) { selectedStatus = .completed }
                        StatusRow(status: .halfDay, isSelected: selectedStatus == .halfDay) { selectedStatus = .halfDay }
                        StatusRow(status: .notDone, isSelected: selectedStatus == .notDone) { selectedStatus = .notDone }
                        StatusRow(status: .restDay, isSelected: selectedStatus == .restDay) { selectedStatus = .restDay }
                        StatusRow(status: .injury, isSelected: selectedStatus == .injury) { selectedStatus = .injury }
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LEVEL NOTES")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.gray)
                        TextField("Add a note about today...", text: $note)
                            .padding()
                            .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255)) // Dark text color
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            if let status = selectedStatus {
                                activityManager.markDate(date, status: status, note: note.isEmpty ? nil : note)
                            }
                            dismiss()
                        }) {
                            Text("Save Status")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.primaryPurple)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }


struct StatusRow: View {
    let status: ActivityStatus
    let isSelected: Bool
    let action: () -> Void
    
    private var statusLabel: String {
        switch status {
        case .completed: return "completed yoga"
        case .halfDay: return "haf day yoga"
        default: return status.rawValue.capitalized
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(status.color)
                    .frame(width: 12, height: 12)
                Text(statusLabel)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(status.color)
                }
            }
            .padding()
            .background(isSelected ? status.color.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(15)
        }
        .foregroundColor(.primary)
    }
}
