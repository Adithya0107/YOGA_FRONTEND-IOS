import SwiftUI
import PhotosUI

struct ProgressViewTab: View {
    @ObservedObject private var zenAPI = ZenAPIService.shared

    // Local editable fields
    @State private var ageInput    = ""
    @State private var weightInput = ""
    @State private var heightInput = ""

    // Journey Shot
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    // UI State
    @State private var showSaveSuccess     = false
    @State private var showShotSuccess     = false
    @State private var isSaving            = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker   = false

    // Consistency grid date range
    @AppStorage("consistencyStartDate") private var startInterval: Double = Date().addingTimeInterval(-90 * 86400).timeIntervalSince1970
    @AppStorage("consistencyEndDate")   private var endInterval: Double   = Date().timeIntervalSince1970

    private var startDate: Date { Date(timeIntervalSince1970: startInterval) }
    private var endDate:   Date { Date(timeIntervalSince1970: endInterval)   }

    private var totalDays: Int {
        let d = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate),
                                                to: Calendar.current.startOfDay(for: endDate)).day ?? 0
        return max(1, d + 1)
    }

    // Count completed days from zenAPI activities in range
    private var completedDays: Int {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let s = Calendar.current.startOfDay(for: startDate)
        let e = Calendar.current.startOfDay(for: endDate)
        return zenAPI.activities.filter { a in
            guard let d = fmt.date(from: a.date) else { return false }
            let day = Calendar.current.startOfDay(for: d)
            return day >= s && day <= e && a.status == "done"
        }.count
    }

    // Activity lookup for grid
    private var activityDict: [String: String] {
        Dictionary(uniqueKeysWithValues: zenAPI.activities.map { ($0.date, $0.status) })
    }

    private let gridFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    // Computed values
    private var bmi: Double { zenAPI.progress.bmi }
    private var healthStatus: String { zenAPI.progress.health_status }
    private var streak: Int { zenAPI.progress.streak_days }
    private var recoveryRate: Int { zenAPI.progress.recovery_rate }

    // Awards milestones
    private var awards: [(days: Int, title: String)] {
        [
            (30,  "April Master"),
            (60,  "May Master"),
            (90,  "June Master")
        ]
    }

    var body: some View {
        ZStack {
            Color(red: 250/255, green: 250/255, blue: 252/255).ignoresSafeArea()

            VStack(spacing: 0) {
                // ── TOP BAR Pinned ──────────────────────────────────────
                LiquidHeaderView(title: "Activity")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {

                    // ── AI ZEN COACH CARD ────────────────────────────────────
                    AIPersonalizedCard()

                    // ── HERO MASTERY JOURNEY ─────────────────────────────────
                    HeroMasteryPathView()
                        .padding(.horizontal, 24)

                    // ── RECENT ACTIVITY (14 days) ────────────────────────────
                    VStack(alignment: .leading, spacing: 15) {
                        Text("RECENT ACTIVITY")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.gray.opacity(0.5))
                            .kerning(1.5)
                            .padding(.horizontal, 24)
                        RecentActivityBar()
                            .padding(.horizontal, 8)
                    }

                    // ── STATS CARDS ──────────────────────────────────────────
                    HStack(spacing: 15) {
                        ActivityStatCard(
                            icon: "clock.fill",
                            iconColor: Color(red: 65/255, green: 182/255, blue: 255/255),
                            value: "1440", // per user request
                            label: "TOTAL MINS"
                        )
                        ActivityStatCard(
                            icon: "waveform.path.ecg",
                            iconColor: Color(red: 34/255, green: 197/255, blue: 94/255),
                            value: "24", // per user request
                            label: "SESSIONS"
                        )
                    }
                    .padding(.horizontal, 24)

                    // ── WEEKLY PERFORMANCE CHART ─────────────────────────────
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("WEEKLY PERFORMANCE")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.gray.opacity(0.5))
                                .kerning(1.5)
                            Spacer()
                            Text("LIVE DATA")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(AppTheme.primaryPurple)
                                .kerning(1)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppTheme.primaryPurple.opacity(0.05))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                        PerformanceBarGraph()
                            .padding(.horizontal, 24)
                    }

                    // ── UPCOMING AWARDS ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 15) {
                        Text("UPCOMING AWARDS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.gray.opacity(0.5))
                            .kerning(1.5)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(awards, id: \.days) { award in
                                    RewardBadge(
                                        day: "\(award.days)",
                                        title: award.title.uppercased(),
                                        isUnlocked: streak >= award.days
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 10)

                    // ── CONSISTENCY GRID (119-day challenge) ─────────────────
                    VStack(alignment: .leading, spacing: 15) {
                        Text("CONSISTENCY IS KEY")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.gray.opacity(0.5))
                            .kerning(1.5)
                            .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 18) {
                            Text("119-Day Challenge")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))

                            // Date range selector
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("START DATE")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.gray.opacity(0.6))
                                    Button { showStartDatePicker.toggle() } label: {
                                        Text(startDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(AppTheme.primaryPurple)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("END DATE")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.gray.opacity(0.6))
                                    Button { showEndDatePicker.toggle() } label: {
                                        Text(endDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(AppTheme.primaryPurple)
                                    }
                                }
                            }
                            .sheet(isPresented: $showStartDatePicker) {
                                NavigationView {
                                    DatePicker("Start", selection: Binding(
                                        get: { startDate },
                                        set: { startInterval = $0.timeIntervalSince1970 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .navigationTitle("Start Date")
                                    .navigationBarItems(trailing: Button("Done") { showStartDatePicker = false })
                                }
                            }
                            .sheet(isPresented: $showEndDatePicker) {
                                NavigationView {
                                    DatePicker("End", selection: Binding(
                                        get: { endDate },
                                        set: { endInterval = $0.timeIntervalSince1970 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .navigationTitle("End Date")
                                    .navigationBarItems(trailing: Button("Done") { showEndDatePicker = false })
                                }
                            }

                            // Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(14), spacing: 5), count: 17),
                                      alignment: .leading, spacing: 5) {
                                ForEach(0..<min(totalDays, 119), id: \.self) { index in
                                    let date = Calendar.current.date(byAdding: .day, value: index, to: startDate)!
                                    let key  = gridFmt.string(from: date)
                                    let status = activityDict[key]
                                    let isToday = Calendar.current.isDateInToday(date)

                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            status == "done"   ? AppTheme.primaryPurple :
                                            status == "missed" ? Color.red.opacity(0.5) :
                                            isToday            ? AppTheme.primaryPurple.opacity(0.2) :
                                                                 Color.gray.opacity(0.15)
                                        )
                                        .frame(width: 14, height: 14)
                                }
                            }

                            HStack {
                                Text("\(completedDays) / \(min(totalDays, 119)) Days Completed")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("🔥 Keep going!")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppTheme.primaryPurple)
                            }

                            // Legend
                            HStack(spacing: 14) {
                                legendItem(color: AppTheme.primaryPurple, label: "Done")
                                legendItem(color: .red.opacity(0.5), label: "Missed")
                                legendItem(color: .gray.opacity(0.15), label: "Future")
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 5)
                        .padding(.horizontal, 24)
                    }

                    // ── HEALTH STATUS + BMI CARD ─────────────────────────────
                    VStack(alignment: .leading, spacing: 15) {
                        Text("HEALTH ANALYSIS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.gray.opacity(0.5))
                            .kerning(1.5)
                            .padding(.horizontal, 24)

                        VStack(spacing: 20) {
                            // Metric inputs
                            HStack(spacing: 15) {
                                MetricInputCard(title: "AGE",    value: $ageInput,    unit: "YRS", icon: "person.fill",   color: .orange)
                                MetricInputCard(title: "WEIGHT", value: $weightInput, unit: "KG",  icon: "scalemass.fill", color: AppTheme.primaryPurple)
                                MetricInputCard(title: "HEIGHT", value: $heightInput, unit: "CM",  icon: "ruler.fill",     color: Color(red: 65/255, green: 182/255, blue: 255/255))
                            }

                            // Health status display
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("HEALTH STATUS")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(.gray.opacity(0.6))
                                        Text(healthStatus)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(AppTheme.primaryPurple)
                                    }
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .stroke(AppTheme.primaryPurple.opacity(0.1), lineWidth: 6)
                                            .frame(width: 50, height: 50)
                                        Circle()
                                            .trim(from: 0, to: CGFloat(recoveryRate) / 100)
                                            .stroke(AppTheme.primaryPurple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                            .frame(width: 50, height: 50)
                                            .rotationEffect(.degrees(-90))
                                        Text("\(recoveryRate)%")
                                            .font(.system(size: 10, weight: .black))
                                    }
                                }

                                Text("BMI: \(String(format: "%.1f", bmi)) — \(healthStatus). Your \(streak)-day streak shows \(streak > 7 ? "strong" : "growing") consistency. Recovery rate \(recoveryRate)%.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)

                                Button(action: {}) {
                                    Text("VIEW FULL ANALYSIS")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(AppTheme.primaryPurple)
                                        .cornerRadius(15)
                                        .shadow(color: AppTheme.primaryPurple.opacity(0.2), radius: 10, y: 5)
                                }
                            }
                            .padding(25)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.05), lineWidth: 1))

                            // Save Changes Button
                            Button(action: saveChanges) {
                                HStack {
                                    if isSaving {
                                        ProgressView().tint(.white)
                                        Text("SAVING...")
                                    } else if showSaveSuccess {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("CHANGES SAVED")
                                    } else {
                                        Image(systemName: "square.and.arrow.down.fill")
                                        Text("SAVE CHANGES")
                                    }
                                }
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(showSaveSuccess ? Color.green : AppTheme.primaryPurple)
                                .cornerRadius(20)
                                .shadow(color: (showSaveSuccess ? Color.green : AppTheme.primaryPurple).opacity(0.2), radius: 10, y: 5)
                                .animation(.easeInOut(duration: 0.3), value: showSaveSuccess)
                            }
                            .disabled(isSaving || showSaveSuccess || ageInput.isEmpty || weightInput.isEmpty || heightInput.isEmpty)
                        }
                        .padding(25)
                        .background(
                            ZStack {
                                Color.white
                                LinearGradient(colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 1)], startPoint: .top, endPoint: .bottom)
                            }
                        )
                        .cornerRadius(35)
                        .shadow(color: Color.black.opacity(0.03), radius: 25, y: 15)
                        .padding(.horizontal, 24)
                    }

                    // ── JOURNEY SHOT CAPTURE ─────────────────────────────────
                    VStack(alignment: .leading, spacing: 15) {
                        Text("JOURNEY SHOT")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.gray.opacity(0.5))
                            .kerning(1.5)
                            .padding(.horizontal, 24)

                        VStack(spacing: 15) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack {
                                    ZStack {
                                        if let data = selectedImageData, let img = UIImage(data: data) {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 55, height: 55)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                        } else {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(AppTheme.primaryPurple.opacity(0.05))
                                                .frame(width: 55, height: 55)
                                            Image(systemName: "camera.viewfinder")
                                                .font(.system(size: 20))
                                                .foregroundColor(AppTheme.primaryPurple)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Tap to capture your transformation")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("Photo + stats will be saved to server")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 10)
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(AppTheme.primaryPurple)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.primaryPurple.opacity(0.1), lineWidth: 1))
                            }
                            .onChange(of: selectedPhotoItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                }
                            }

                            // Upload button
                            Button(action: uploadJourneyShot) {
                                HStack {
                                    if showShotSuccess {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("SHOT SAVED!")
                                    } else {
                                        Image(systemName: "camera.fill")
                                        Text("UPLOAD JOURNEY SHOT")
                                    }
                                }
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(showShotSuccess ? Color.green : AppTheme.primaryPurple)
                                .cornerRadius(18)
                                .shadow(color: (showShotSuccess ? Color.green : AppTheme.primaryPurple).opacity(0.2), radius: 8, y: 4)
                            }
                            .disabled(selectedImageData == nil || showShotSuccess)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.03), radius: 20, y: 10)
                        .padding(.horizontal, 24)
                    }

                    // ── JOURNEY SHOT HISTORY ─────────────────────────────────
                    if !zenAPI.journeyShots.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("JOURNEY SHOT HISTORY")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.gray.opacity(0.5))
                                .kerning(1.5)
                                .padding(.horizontal, 24)

                            VStack(spacing: 12) {
                                ForEach(zenAPI.journeyShots) { shot in
                                    HStack(spacing: 15) {
                                        // Placeholder image (server images need URL loading)
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(AppTheme.primaryPurple.opacity(0.1))
                                            .frame(width: 60, height: 60)
                                            .overlay(Image(systemName: "figure.yoga").foregroundColor(AppTheme.primaryPurple).font(.system(size: 22)))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formatDate(shot.created_at))
                                                .font(.system(size: 14, weight: .bold))
                                            HStack(spacing: 8) {
                                                Text("\(shot.age)y")
                                                Text("\(shot.weight)kg")
                                                Text("\(shot.height)cm")
                                                Text(shot.status)
                                                    .foregroundColor(AppTheme.primaryPurple)
                                            }
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.gray)
                                            Text("BMI \(String(format: "%.1f", shot.bmi))")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(AppTheme.primaryPurple.opacity(0.7))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.gray.opacity(0.3))
                                    }
                                    .padding(15)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.01), radius: 5, y: 5)
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
            }
        }
    }
    .onAppear {
            zenAPI.fetchAll()
            // Pre-fill from existing progress
            if zenAPI.progress.sessions > 0 {
                ageInput    = "\(zenAPI.progress.recovery_rate)"
            }
        }
    }

    // ── HELPER VIEWS ─────────────────────────────────────────────────────────

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.gray)
        }
    }

    // ── ACTIONS ───────────────────────────────────────────────────────────────

    private func saveChanges() {
        guard let a = Int(ageInput), let w = Int(weightInput), let h = Int(heightInput) else { return }
        isSaving = true
        zenAPI.saveChanges(age: a, weight: w, height: h) { success, _ in
            isSaving = false
            if success {
                withAnimation { showSaveSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showSaveSuccess = false
                }
            }
        }
    }

    private func uploadJourneyShot() {
        guard let data = selectedImageData,
              let a = Int(ageInput), let w = Int(weightInput), let h = Int(heightInput) else { return }
        let bmiVal = Double(w) / pow(Double(h) / 100.0, 2)
        let status = bmiVal < 18.5 ? "Underweight" : bmiVal < 25 ? "Optimal Balance" : bmiVal < 30 ? "Strength Needed" : "Heavy Load"
        zenAPI.uploadJourneyShot(imageData: data, age: a, weight: w, height: h, status: status) { success in
            if success {
                selectedImageData = nil
                selectedPhotoItem = nil
                withAnimation { showShotSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showShotSuccess = false }
            }
        }
    }

    private func formatDate(_ str: String) -> String {
        let input  = DateFormatter(); input.dateFormat  = "yyyy-MM-dd HH:mm:ss"
        let output = DateFormatter(); output.dateFormat = "MMM d, yyyy"
        if let d = input.date(from: str) { return output.string(from: d) }
        return str
    }
}

// MARK: - Inline metric input card (replaces ModernMetricCard binding dependency)
struct MetricInputCard: View {
    let title: String
    @Binding var value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            TextField("0", text: $value)
                .keyboardType(.numberPad)
                .font(.system(size: 18, weight: .black))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
            Text(unit)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.gray.opacity(0.5))
                .kerning(1)
            Text(title)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(color.opacity(0.8))
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(color.opacity(0.06))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.1), lineWidth: 1))
    }
}
