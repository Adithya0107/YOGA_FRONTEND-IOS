import SwiftUI

struct HeroMasteryPathView: View {
    @ObservedObject private var zenAPI = ZenAPIService.shared

    let levels: [(lvl: Int, name: String, desc: String, days: Int, icon: String)] = [
        (0, "BEGINNER",   "Starting the journey",       0,   "leaf.fill"),
        (1, "DEDICATED",  "Consistency unlocked",       15,  "bolt.fill"),
        (2, "MASTER",     "Strength mastery",           30,  "flame.fill"),
        (3, "ELITE",      "Peak performance",           60,  "star.fill"),
        (4, "ZEN MASTER", "Elite transformation",       150, "sparkles")
    ]

    private var currentStreak: Int { zenAPI.progress.streak_days }
    private var currentLevel: Int { zenAPI.progress.level }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("HERO MASTERY JOURNEY")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.gray.opacity(0.5))
                .kerning(1.5)

            VStack(spacing: 0) {
                ForEach(0..<levels.count, id: \.self) { index in
                    let lvl = levels[index]
                    let isUnlocked = currentStreak >= lvl.days
                    let isCurrent = currentLevel == lvl.lvl

                    HStack(alignment: .top, spacing: 20) {
                        // Node + connector line
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(isUnlocked
                                          ? AppTheme.primaryPurple
                                          : Color.gray.opacity(0.12))
                                    .frame(width: 34, height: 34)
                                    .shadow(color: isUnlocked ? AppTheme.primaryPurple.opacity(0.35) : .clear, radius: 6)

                                Image(systemName: isUnlocked ? "checkmark" : "lock.fill")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundColor(isUnlocked ? .white : .gray.opacity(0.4))

                                if isCurrent {
                                    Circle()
                                        .stroke(AppTheme.primaryPurple, lineWidth: 2.5)
                                        .frame(width: 44, height: 44)
                                        .scaleEffect(1.0)
                                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isCurrent)
                                }
                            }

                            if index < levels.count - 1 {
                                Rectangle()
                                    .fill(isUnlocked && currentStreak >= levels[index + 1].days
                                          ? AppTheme.primaryPurple
                                          : Color.gray.opacity(0.1))
                                    .frame(width: 2, height: 52)
                            }
                        }

                        // Text info
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: lvl.icon)
                                    .font(.system(size: 12))
                                    .foregroundColor(isUnlocked ? AppTheme.primaryPurple : .gray.opacity(0.3))
                                Text(lvl.name)
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(isUnlocked ? Color.black : .gray.opacity(0.35))
                            }
                            Text(lvl.desc)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)

                            if !isUnlocked {
                                let daysLeft = max(0, lvl.days - currentStreak)
                                Text("\(daysLeft) days to unlock")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(AppTheme.primaryPurple.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.primaryPurple.opacity(0.07))
                                    .cornerRadius(6)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, 5)
                        .opacity(isUnlocked ? 1 : 0.55)

                        Spacer()

                        if isUnlocked {
                            Text("LEVEL \(lvl.lvl)")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(AppTheme.primaryPurple)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.primaryPurple.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.top, 5)
                        }
                    }
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(35)
            .shadow(color: Color.black.opacity(0.02), radius: 20, y: 10)
        }
    }
}
