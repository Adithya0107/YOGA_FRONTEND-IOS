import SwiftUI

struct DailyScheduleSection: View {
    let goal: String
    @ObservedObject private var apiService = ZenAPIService.shared
    
    // Mock schedule based on goal (Fallback)
    private var mockSchedule: [(time: String, title: String, subtitle: String, icon: String, iconColor: Color)] {
        if goal == "Lose Weight" {
            return [
                ("06:30 AM", "Hydration & Warm-up", "500ml Water + Joint Circles", "drop.fill", .blue),
                ("07:00 AM", "Weight Loss Flow", "45 min Metabolic Ignition", "bolt.fill", .orange),
                ("08:30 AM", "Balanced Breakfast", "High Protein + Fiber", "leaf.fill", .green),
                ("12:30 PM", "Afternoon Metabolism", "10 min Walking Meditation", "figure.walk", .teal),
                ("06:00 PM", "Core Blast", "15 min Core Stability", "flame.fill", .red),
                ("09:00 PM", "Deep Stretch", "Relaxation for Sleep", "moon.stars", .purple)
            ]
        } else if goal == "Gain Muscle" {
            return [
                ("07:00 AM", "Protein Shake", "Muscle Fuel", "wineglass.fill", .pink),
                ("07:30 AM", "Power Yoga Flow", "60 min Strength & Resistance", "bolt.fill", .orange),
                ("12:00 PM", "Nutrient Dense Lunch", "Clean Carbs + Lean Protein", "fork.knife", .green),
                ("05:30 PM", "Aerial Strength Drills", "30 min Hammock Conditioning", "sparkles", .purple),
                ("08:00 PM", "Recovery Session", "Myofascial Release", "heart.fill", .red),
                ("10:00 PM", "Restorative Sleep", "8 Hours Recovery", "bed.double.fill", .blue)
            ]
        } else {
            return [
                ("07:00 AM", "Breathing Technique", "15 min Pranayama", "wind", .blue),
                ("08:00 AM", "Morning Flexibility", "30 min Full Body Stretch", "figure.curling", .teal),
                ("01:00 PM", "Mindful Lunch", "Unplugged Eating", "leaf.fill", .green),
                ("06:00 PM", "Stress Relief Yoga", "45 min Evening Unwind", "heart.fill", .red),
                ("09:30 PM", "Gratitude Journaling", "Reflect on Peace", "pencil.and.outline", .orange),
                ("10:30 PM", "Deep Relaxation", "Sleep Meditation", "moon.stars", .purple)
            ]
        }
    }

    private var displaySchedule: [(time: String, title: String, subtitle: String, icon: String, iconColor: Color)] {
        if !apiService.dailyPlan.isEmpty {
            // Use the first day for now
            let day1 = apiService.dailyPlan[0]
            if let poses = day1["poses"] as? [[String: Any]] {
                return poses.enumerated().map { (index, pose) in
                    let time = index == 0 ? "07:00 AM" : index == 1 ? "08:30 AM" : index == 2 ? "01:00 PM" : index == 3 ? "06:00 PM" : "09:30 PM"
                    return (time, pose["name"] as? String ?? "Pose", pose["description"] as? String ?? "", "figure.yoga", .purple)
                }
            }
        }
        return mockSchedule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DAILY SCHEDULE")
                .font(.system(size: 13, weight: .black))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                .kerning(0.5)
            
            VStack(spacing: 0) {
                ForEach(0..<displaySchedule.count, id: \.self) { index in
                    ScheduleRow(item: displaySchedule[index], isLast: index == displaySchedule.count - 1)
                }
            }
            .padding(25)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.04), radius: 15, y: 10)
        }
    }
}

struct ScheduleRow: View {
    let item: (time: String, title: String, subtitle: String, icon: String, iconColor: Color)
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(item.iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: item.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(item.iconColor)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(item.time)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(item.iconColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(item.iconColor.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                    Text(item.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, isLast ? 0 : 25)
            }
        }
    }
}
