import SwiftUI
import PhotosUI

struct ProgressViewTab: View {
    @ObservedObject private var zenAPI = ZenAPIService.shared
    @ObservedObject private var activityManager = ActivityManager.shared

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
    @State private var showAnalysis        = false

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
    private var bmi: Double {
        if let w = Double(weightInput), let h = Double(heightInput), h > 0 {
            return w / pow(h / 100.0, 2)
        }
        return zenAPI.progress.bmi
    }
    
    private var healthStatus: String {
        let currentBMI = bmi
        if currentBMI == 0 { return zenAPI.progress.health_status }
        if currentBMI < 18.5 { return "Underweight" }
        if currentBMI < 25 { return "Normal" }
        if currentBMI < 30 { return "Overweight" }
        return "Obese"
    }
    
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
            ZenBackgroundView()

            VStack(spacing: 0) {
                // ── TOP BAR Pinned ──────────────────────────────────────
                LiquidHeaderView(title: "Activity")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {

                    // Empty space for padding under header
                    Spacer().frame(height: 10)

                    // ── STATS CARDS ──────────────────────────────────────────
                    HStack(spacing: 15) {
                        ActivityStatCard(
                            icon: "flame.fill",
                            iconColor: Color.orange,
                            value: "\(activityManager.totalCalories)",
                            label: "TOTAL CALORIES"
                        )
                        ActivityStatCard(
                            icon: "waveform.path.ecg",
                            iconColor: Color(red: 34/255, green: 197/255, blue: 94/255),
                            value: "\(activityManager.sessionRecords.count)",
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
                                if showAnalysis {
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
                                    .transition(.opacity.combined(with: .move(edge: .top)))

                                    Text("BMI: \(String(format: "%.1f", bmi)) — \(healthStatus). Your \(streak)-day streak shows \(streak > 7 ? "strong" : "growing") consistency. Recovery rate \(recoveryRate)%.")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                        .lineSpacing(4)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }

                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        showAnalysis.toggle()
                                    }
                                }) {
                                    Text(showAnalysis ? "HIDE ANALYSIS" : "VIEW FULL ANALYSIS")
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
                            .glassCard(cornerRadius: 25)

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
                        .glassCard(cornerRadius: 35)
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
                            let streak = Int(zenAPI.progress.streak_days)
                            let shotsCount = zenAPI.journeyShots.count
                            let canUpload = streak >= 15 && (streak / 15) > shotsCount
                            let nextMilestone = ((shotsCount + 1) * 15)
                            let daysToNext = nextMilestone - streak

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
                                                .fill(canUpload ? AppTheme.primaryPurple.opacity(0.05) : Color.gray.opacity(0.05))
                                                .frame(width: 55, height: 55)
                                            Image(systemName: canUpload ? "camera.viewfinder" : "lock.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(canUpload ? AppTheme.primaryPurple : .gray.opacity(0.5))
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(canUpload ? "Tap to capture your transformation" : "Journey Shot Locked")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(canUpload ? .black : .gray)
                                        
                                        if canUpload {
                                            Text("Photo + stats will be saved to server")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("Complete \(daysToNext) more days streak to unlock")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.primaryPurple.opacity(0.7))
                                        }
                                    }
                                    .padding(.leading, 10)
                                    Spacer()
                                    
                                    if canUpload {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(AppTheme.primaryPurple)
                                    }
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(canUpload ? AppTheme.primaryPurple.opacity(0.1) : Color.gray.opacity(0.1), lineWidth: 1))
                            }
                            .disabled(!canUpload)
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
                                        Image(systemName: canUpload ? "camera.fill" : "lock.fill")
                                        Text(canUpload ? "UPLOAD JOURNEY SHOT" : "LOCKED")
                                    }
                                }
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(showShotSuccess ? Color.green : (canUpload ? AppTheme.primaryPurple : Color.gray.opacity(0.3)))
                                .cornerRadius(18)
                                .shadow(color: (showShotSuccess ? Color.green : (canUpload ? AppTheme.primaryPurple : Color.clear)).opacity(0.2), radius: 8, y: 4)
                            }
                            .disabled(!canUpload || selectedImageData == nil || showShotSuccess)
                        }
                        .padding(20)
                        .glassCard(cornerRadius: 30)
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
