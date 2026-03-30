import SwiftUI

struct DailyScheduleSection: View {
    let goal: String
    @ObservedObject private var apiService = ZenAPIService.shared
    
    // Diet-focused schedule based on goal
    private var dietSchedule: [(time: String, title: String, subtitle: String, icon: String, iconColor: Color)] {
        if goal.contains("Weight") || goal.contains("Fat") {
            return [
                ("08:00 AM", "Breakfast: Oats & Fruits", "Fiber-rich start for metabolism", "bowl.fill", .orange),
                ("11:00 AM", "Mid-Morning: Green Tea", "Antioxidant boost", "leaf.fill", .green),
                ("01:30 PM", "Lunch: Veggie & Rice", "Light and balanced nutrition", "fork.knife", .blue),
                ("05:00 PM", "Snack: Mixed Nuts", "Healthy fats + Protein", "sparkles", .purple),
                ("08:00 PM", "Dinner: Soup & Salad", "Light night-time digestion", "moon.stars", .indigo),
                ("09:30 PM", "Detox: Warm Water", "Cleanse before sleep", "drop.fill", .teal)
            ]
        } else if goal.contains("Muscle") || goal.contains("Gain") {
            return [
                ("07:30 AM", "Breakfast: Eggs & Milk", "Muscle fuel protein start", "egg.fill", .yellow),
                ("10:30 AM", "Snack: Banana & Nuts", "Quick energy for repair", "banana.fill", .orange),
                ("01:30 PM", "Lunch: Chicken/Paneer & Rice", "High protein clean calories", "fork.knife", .red),
                ("05:30 PM", "Snack: Protein Shake", "Post-activity recovery", "wineglass.fill", .pink),
                ("08:30 PM", "Dinner: Chapati & Dal", "Solid recovery nutrition", "mouth.fill", .brown),
                ("10:00 PM", "Sleep: Casein Source", "Sustained muscle repair", "bed.double.fill", .blue)
            ]
        } else {
            // General Wellness / Vegetarian focused
            return [
                ("08:00 AM", "Breakfast: Oats & Banana", "Sattvic morning energy", "leaf.fill", .green),
                ("11:30 AM", "Snack: Seasonal Fruits", "Natural vitamins & minerals", "applelogo", .orange),
                ("01:30 PM", "Lunch: Dal, Rice & Veg", "Complete vegetarian protein", "fork.knife", .blue),
                ("05:00 PM", "Snack: Sprouts/Yogurt", "Digestive health boost", "carrot.fill", .orange),
                ("08:00 PM", "Dinner: Paneer & Salad", "Light and nourishing", "sparkles", .purple),
                ("09:30 PM", "Night: Warm Turmeric Milk", "Healing & anti-inflammatory", "moon.stars", .yellow)
            ]
        }
    }

    private var displaySchedule: [(time: String, title: String, subtitle: String, icon: String, iconColor: Color)] {
        return dietSchedule
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DAILY DIET PLAN")
                .font(.system(size: 13, weight: .black))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                .kerning(0.5)
            
            VStack(spacing: 0) {
                ForEach(0..<displaySchedule.count, id: \.self) { index in
                    ScheduleRow(item: displaySchedule[index], isLast: index == displaySchedule.count - 1)
                }
            }
            .padding(25)
            .glassCard(cornerRadius: 30)
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
