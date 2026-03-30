import SwiftUI

struct HomeDashboardView: View {
    @Binding var selectedTab: Int
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("userFullName") private var fullName = "Alex"
    @AppStorage("userExperience") private var experience = "Beginner"
    @AppStorage("userGoal") private var goal = "Fat loss + Core strength"
    @AppStorage("userAge") private var age = "18-24"
    @AppStorage("userWorkoutPreference") private var workoutPreference = "Morning"
    
    @ObservedObject private var apiService = ZenAPIService.shared
    @ObservedObject private var activityManager = ActivityManager.shared

    @State private var showFullCalendar = false
    @State private var showSideMenu = false
    @State private var selectedDateForEdit: Date?
    @State private var showDateEditSheet = false
    
    // Dynamic Greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    // Logic for Dynamic Tasks based on onboarding info
    private var dynamicTasks: [(title: String, time: String, icon: String, isCompleted: Bool, isOngoing: Bool)] {
        var tasks: [(title: String, time: String, icon: String, isCompleted: Bool, isOngoing: Bool)] = []
        
        // Task 1: Meal/Nutrition
        if goal == "Lose Weight" || goal == "Fat loss + Core strength" {
            tasks.append(("Protein Breakfast", "08:00 AM", "leaf.fill", true, false))
        } else {
            tasks.append(("Hydration Intake", "07:30 AM", "drop.fill", true, false))
        }
        
        // Task 2: Primary Workout (personalized by Age & Goal)
        if age == "18-24" && (goal.contains("Fat loss") || goal.contains("Core")) {
            tasks.append(("Core Strength Flow", "ONGOING", "sparkles", false, true))
        } else if experience == "Beginner" {
            tasks.append(("Beginner Yoga Stretch", "ONGOING", "figure.yoga", false, true))
        } else {
            tasks.append(("Advanced Power Flow", "ONGOING", "bolt.fill", false, true))
        }
        
        // Task 3: Recovery
        tasks.append(("Stretch & Recovery", "11:30 AM", "heart.fill", false, false))
        
        return tasks
    }
    
    private var proLevel: String {
        "Level \(activityManager.proLevel)"
    }
    
    var body: some View {
        ZStack {
            ZenBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar - Pinned
                LiquidHeaderView(
                    title: fullName.isEmpty ? "Alex" : (fullName.components(separatedBy: .whitespaces).first ?? "Alex"),
                    showMenuButton: true,
                    menuAction: { showSideMenu = true }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        
                        // Neumorphic Stats Area
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                StatsCard(
                                    title: "DAY STREAK",
                                    value: "\(apiService.progress.streak_days)",
                                    subtitle: "days",
                                    icon: "flame.fill",
                                    iconColor: Color(red: 251/255, green: 146/255, blue: 60/255)
                                )
                                .frame(width: 175)
                                
                                StatsCard(
                                    title: "TOTAL TIME",
                                    value: "\(activityManager.totalPracticeMinutes)",
                                    subtitle: "min",
                                    icon: "clock.fill",
                                    iconColor: AppTheme.primaryPurple
                                )
                                .frame(width: 175)
                                
                                StatsCard(
                                    title: "LEVEL",
                                    value: "\(activityManager.proLevel)",
                                    subtitle: "",
                                    icon: "star.fill",
                                    iconColor: Color(red: 65/255, green: 182/255, blue: 255/255)
                                )
                                .frame(width: 175)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Weekly Activity Tracker
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("YOUR ACTIVITY")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(AppTheme.primaryPurple)
                                    .kerning(0.5)
                                Spacer()
                                Text("THIS WEEK")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                            .padding(.horizontal, 24)
                            
                            WeeklyCalendarView(onDayTap: { date in
                                selectedDateForEdit = date
                                showDateEditSheet = true
                            })
                            .padding(.horizontal, 24)
                            
                            .padding(.horizontal, 24)
                            
                            Button(action: { showFullCalendar = true }) {
                                Text("View All Months")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppTheme.primaryPurple)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .glassCard(cornerRadius: 15)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // DAY WISE SCHEDULE
                        DailyScheduleSection(goal: goal)
                            .padding(.horizontal, 24)
                        
                        
                        
                        // AI Smart Recommendation Card
                        AISmartPlanCard(selectedTab: $selectedTab)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                    .padding(.bottom, 20)
                    
                    // Navigation Destinations (Push/Pop)
                    NavigationLink(destination: SideMenuView(selectedTab: $selectedTab, isPresented: $showSideMenu), isActive: $showSideMenu) { EmptyView() }
                    NavigationLink(destination: AdvancedCalendarView(), isActive: $showFullCalendar) { EmptyView() }
                    NavigationLink(destination: Group {
                        if let date = selectedDateForEdit {
                            DateEditSheet(date: date)
                        }
                    }, isActive: $showDateEditSheet) { EmptyView() }
                }
            }
        }
        .onAppear {
            apiService.fetchAll()
        }
    }
}
