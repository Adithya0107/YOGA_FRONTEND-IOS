import SwiftUI
import Combine

struct PracticeDetailView: View {
    @Environment(\.dismiss) var dismiss
    let style: YogaStyle
    @State var currentIndex: Int
    
    // Pose-level timer
    @State private var timeLeft: Int = 0
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Session tracker
    @StateObject private var tracker: YogaSessionTracker
    @State private var showCompletionSheet = false
    @State private var completedRecord: SessionRecord?
    
    init(style: YogaStyle, currentIndex: Int) {
        self.style = style
        self._currentIndex = State(initialValue: currentIndex)
        self._tracker = StateObject(wrappedValue: YogaSessionTracker(style: style))
    }
    
    var currentPose: YogaPose {
        style.poses[currentIndex]
    }
    
    private func activeTimerString(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
    
    private func poseTimerString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // === SESSION ACTIVE HUD ===
                // Always show HUD if it's open, to see Target and Current progress
                HStack(spacing: 0) {
                    // Active time counter (Green Timer)
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 34/255, green: 197/255, blue: 94/255))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isTimerRunning ? 1.3 : 1)
                            .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isTimerRunning)
                        Text(activeTimerString(tracker.activeSeconds))
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 34/255, green: 197/255, blue: 94/255))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // TARGET - Goal for this session
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("TARGET")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white.opacity(0.6))
                            .kerning(1)
                        Text(activeTimerString(style.level.minPracticeTime))
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.primaryPurple)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 14/255, green: 17/255, blue: 27/255))
                
                // === HEADER ===
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                            Text("CANCEL")
                                .font(.system(size: 12, weight: .black))
                        }
                        .foregroundColor(Color.red.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(20)
                    }
                    Spacer()
                    
                    // Finish Session button
                    if tracker.isSessionActive {
                        Button(action: { finishSession() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "flag.checkered")
                                    .font(.system(size: 13, weight: .bold))
                                Text("FINISH")
                                    .font(.system(size: 12, weight: .black))
                            }
                            .foregroundColor(AppTheme.primaryPurple)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppTheme.primaryPurple.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // === POSE CONTENT ===
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("STEP \(currentPose.stepNumber) OF \(style.poses.count)")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(AppTheme.primaryPurple)
                            .kerning(1.5)
                        
                        Spacer()
                        
                        // Pose timer
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                            Text(poseTimerString(timeLeft))
                                .monospacedDigit()
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primaryPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryPurple.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Text(currentPose.title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text(currentPose.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Pose Image
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.gray.opacity(0.05))
                        
                        if let imageName = currentPose.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                        } else {
                            VStack(spacing: 15) {
                                Image(systemName: currentPose.iconName)
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.primaryPurple.opacity(0.3))
                                Text("Positioning Visualization")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                resetPoseTimerForNavigation()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(currentIndex > 0 ? .black : .gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex == 0)
                        
                        Button(action: { 
                            if !tracker.isSessionActive {
                                tracker.startSession()
                            }
                            isTimerRunning.toggle() 
                        }) {
                            HStack {
                                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                Text(isTimerRunning ? "PAUSE" : "START TIMER")
                                    .font(.system(size: 14, weight: .black))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(18)
                        }
                        
                        Button(action: {
                            if currentIndex < style.poses.count - 1 {
                                currentIndex += 1
                                resetPoseTimerForNavigation()
                            } else {
                                isTimerRunning = false
                                finishSession()
                            }
                        }) {
                            Image(systemName: currentIndex < style.poses.count - 1 ? "chevron.right" : "flag.checkered")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(25)
            }
        }
        .onAppear {
            resetPoseTimer()
            // Do NOT start session automatically here. 
            // We wait for the "START TIMER" button.
            tracker.isSessionActive = false
            tracker.activeSeconds = 0
            tracker.watchedSeconds = 0
        }
        .onDisappear {
            if tracker.isSessionActive {
                tracker.stopSession()
            }
        }
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }
            
            // Increment Session Timer (Upward) - capped at target
            tracker.tick()
            
            // Decrement Pose Timer (Downward)
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                // Countdown finished for current pose
                if currentIndex < style.poses.count - 1 {
                    // Auto advance to next pose
                    currentIndex += 1
                    // After moving to next pose, countdown resets and stays running
                    timeLeft = style.poses[currentIndex].duration
                } else {
                    // Final pose finished
                    isTimerRunning = false
                    finishSession()
                }
            }
        }
        .fullScreenCover(isPresented: $showCompletionSheet) {
            if let record = completedRecord {
                SessionCompletionView(record: record) {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func resetPoseTimer() {
        if currentIndex >= 0 && currentIndex < style.poses.count {
            timeLeft = style.poses[currentIndex].duration
        }
        isTimerRunning = false
    }
    
    // NAVIGATION specific reset: adjust timeLeft but keep running state if practicing
    func resetPoseTimerForNavigation() {
        if currentIndex >= 0 && currentIndex < style.poses.count {
            timeLeft = style.poses[currentIndex].duration
        }
        // Requirement 1 says all paused initially. Navigation doesn't explicitly 
        // say it should pause. Keeping the user in their current flow state is standard.
        // But if they haven't "started" yet, it stays paused.
        if !tracker.isSessionActive {
            isTimerRunning = false
        }
    }
    
    func finishSession() {
        tracker.stopSession()
        
        let status = tracker.calculateStatus()
        let completion = min(100.0, Double(tracker.watchedSeconds) / Double(max(1, style.totalDuration)) * 100.0)
        
        let record = SessionRecord(
            id: UUID(),
            date: Date(),
            styleName: style.name,
            level: style.level,
            totalVideoDuration: style.totalDuration,
            actualPracticeTime: tracker.activeSeconds,
            completionPercentage: completion,
            status: status,
            caloriesBurned: tracker.calculateCalories()
        )
        
        ActivityManager.shared.addSessionRecord(record)
        completedRecord = record
        showCompletionSheet = true
    }
}
