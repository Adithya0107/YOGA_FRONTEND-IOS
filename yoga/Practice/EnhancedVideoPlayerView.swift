import SwiftUI
import Combine

struct EnhancedVideoPlayerView: View {
    @Environment(\.dismiss) var dismiss
    let style: YogaStyle
    
    @StateObject private var tracker: YogaSessionTracker
    @State private var isPracticing = false // Wait for video to signal "Playing"
    @State private var showCompletionCelebration = false
    @State private var opacity: Double = 0
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    @State private var isFullScreen: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(style: YogaStyle) {
        self.style = style
        self._tracker = StateObject(wrappedValue: YogaSessionTracker(style: style))
    }
    
    private var videoId: String {
        let original = style.videoURL ?? ""
        if original.contains("v=") {
            return original.components(separatedBy: "v=").last?.components(separatedBy: "&").first ?? ""
        } else if original.contains("youtu.be/") {
            return original.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first ?? ""
        } else if original.contains("/file/d/") {
            let parts = original.components(separatedBy: "/file/d/")
            if parts.count > 1 {
                return parts[1].components(separatedBy: "/").first ?? "unknown"
            }
        }
        return original
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isFullScreen {
                fullScreenVideoLayout
            } else if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .onAppear {
            updateOrientation()
            withAnimation(.easeIn(duration: 0.5)) { opacity = 1 }
            tracker.startSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            withAnimation { updateOrientation() }
        }
        .onReceive(timer) { _ in
            // Precision Sync: Timer only ticks if video is actively playing
            if isPracticing {
                tracker.tick()
            }
        }
        .statusBar(hidden: isFullScreen || isLandscape)
        .navigationBarHidden(true)
    }
    
    private func updateOrientation() {
        let orientation = UIDevice.current.orientation
        if orientation.isValidInterfaceOrientation {
            isLandscape = orientation.isLandscape
            // Auto exit full screen if rotated to portrait and it wasn't manual? 
            // Or just keep it. Let's keep it.
        }
    }
    
    // MARK: - Layouts
    
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            headerBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    videoSection
                    statsSection
                    progressSection
                    classDetailsSection
                }
                .padding(.vertical, 10)
                .padding(.bottom, 100)
            }
            .opacity(opacity)
            
            bottomControls
        }
        .overlay(completionOverlay)
    }
    
    private var landscapeLayout: some View {
        HStack(spacing: 0) {
            // Left: Large Video
            ZStack(alignment: .bottomTrailing) {
                YouTubePlayerView(videoURL: style.videoURL ?? "", isPlaying: $isPracticing, cornerRadius: 0, shadowRadius: 0) { state in
                    DispatchQueue.main.async {
                        isPracticing = (state == 1)
                        if state == 0 { finishSession() }
                    }
                }
                .ignoresSafeArea()
                
                // Overlay Controls
                videoOverlayControls
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Right: Minimal Stats & Controls
            VStack(spacing: 20) {
                HStack {
                    Text(style.name.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(AppTheme.primaryPurple)
                    Spacer()
                    Button(action: { 
                        finishSession()
                        dismiss() 
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.3))
                            .font(.system(size: 24))
                    }
                }
                .padding(.top, 10)
                
                HStack(spacing: 10) {
                    MiniStat(icon: "flame.fill", label: "CAL", value: "\(tracker.calculateCalories())", color: .orange)
                    MiniStat(icon: "timer", label: "LEFT", value: timeString(max(0, style.level.minPracticeTime - tracker.activeSeconds)), color: AppTheme.primaryPurple)
                }
                
                Spacer()
                
                Button(action: { isPracticing.toggle() }) {
                    Image(systemName: isPracticing ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(isPracticing ? .orange : AppTheme.primaryPurple)
                }
                
                Button(action: { finishSession() }) {
                    Text("FINISH")
                        .font(.system(size: 12, weight: .black))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.bottom, 10)
            }
            .frame(width: 140)
            .padding(.horizontal, 15)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 10, x: -5, y: 0)
        }
        .overlay(completionOverlay)
    }

    private var fullScreenVideoLayout: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.ignoresSafeArea()
            
            YouTubePlayerView(videoURL: style.videoURL ?? "", isPlaying: $isPracticing, cornerRadius: 0, shadowRadius: 0) { state in
                DispatchQueue.main.async {
                    isPracticing = (state == 1)
                    if state == 0 { finishSession() }
                }
            }
            .ignoresSafeArea()
            
            videoOverlayControls
            
            // Exit Full Screen Button (Top Left)
            VStack {
                HStack {
                    Button(action: { withAnimation { isFullScreen = false } }) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(20)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    private var videoOverlayControls: some View {
        VStack {
            Spacer()
            HStack {
                // Time Display
                HStack(spacing: 6) {
                    Image(systemName: isPracticing ? "timer" : "timer.circle")
                        .font(.system(size: 10, weight: .bold))
                    Text(timeString(tracker.activeSeconds))
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                
                Spacer()
                
                // Full Screen Button
                Button(action: { withAnimation { isFullScreen.toggle() } }) {
                    Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
            .padding(12)
        }
    }
    
    // MARK: - Sub-Views (Portrait Focused)
    
    private var headerBar: some View {
        HStack {
            Button(action: { 
                finishSession()
                dismiss() 
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                    .padding(12)
                    .background(Circle().fill(AppTheme.primaryPurple.opacity(0.1)))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(style.name.uppercased())
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(AppTheme.primaryPurple)
                    .kerning(1.5)
                Text("Session Activity")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }
    
    private var videoSection: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                RoundedRectangle(cornerRadius: isFullScreen ? 0 : 20)
                    .fill(Color.black)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.12), radius: 20, x: 0, y: 12)
                
                YouTubePlayerView(videoURL: style.videoURL ?? "", isPlaying: $isPracticing, cornerRadius: 20, shadowRadius: 0) { state in
                    DispatchQueue.main.async {
                        isPracticing = (state == 1)
                        if state == 0 { finishSession() }
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit) // Fit ensures we see the whole "inside video"
            .background(Color.black)
            
            videoOverlayControls
        }
        .padding(.horizontal, isFullScreen ? 0 : 8) // Maximum enlargement for portrait
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatBox(title: "CALORIES", value: "\(tracker.calculateCalories())", icon: "flame.fill", color: .orange)
            StatBox(title: "INTENSITY", value: style.level.rawValue.uppercased(), icon: "chart.bar.fill", color: AppTheme.primaryPurple)
        }
        .padding(.horizontal, 20)
    }
    
    private var progressSection: some View {
        VStack(spacing: 14) {
            let percentage = min(1.0, Double(tracker.activeSeconds) / Double(max(1, style.totalDuration)))
            HStack {
                Text("\(Int(percentage * 100.0))% COMPLETED")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
                Spacer()
                Text(timeString(max(0, style.totalDuration - tracker.activeSeconds)))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
            }
            .padding(.horizontal, 4)
            
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.08)).frame(height: 8)
                Capsule()
                    .fill(AppTheme.primaryPurple)
                    .frame(width: max(16, CGFloat(percentage) * (UIScreen.main.bounds.width - 40)), height: 8)
                    .animation(.linear(duration: 0.2), value: tracker.activeSeconds)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var classDetailsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("CLASS DETAILS")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    DetailCard(title: "Benefits", value: "Flexibility & Peace", icon: "sparkles", color: .blue)
                    DetailCard(title: "Focus", value: "Breathing", icon: "wind", color: .green)
                    DetailCard(title: "Music", value: "Zen Ambient", icon: "music.note", color: .purple)
                }
                .padding(.horizontal, 20)
            }
            
            if let firstPose = style.poses.first {
                posePreviewCard(pose: firstPose)
            }
        }
    }
    
    private func posePreviewCard(pose: YogaPose) -> some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(AppTheme.primaryPurple.opacity(0.05)).frame(width: 48, height: 48)
                Image(systemName: "figure.yoga").foregroundColor(AppTheme.primaryPurple)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("CURRENT FOCUS").font(.system(size: 9, weight: .black)).foregroundColor(.gray.opacity(0.5))
                Text(pose.title).font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.primaryPurple)
            }
            Spacer()
            Text("\(pose.duration)s").font(.system(size: 12, weight: .bold)).foregroundColor(.gray.opacity(0.6))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.06), lineWidth: 1))
        .padding(.horizontal, 20)
    }
    
    private var bottomControls: some View {
        HStack(spacing: 16) {
            let percentage = Double(tracker.activeSeconds) / Double(max(1, style.totalDuration))
            let isDone = percentage >= 1.0 || showCompletionCelebration
            
            Button(action: {
                if !tracker.isSessionActive { tracker.startSession() }
                if !isDone { isPracticing.toggle() }
            }) {
                HStack(spacing: 10) {
                    if isDone {
                        Text("COMPLETED ✓").font(.system(size: 14, weight: .black))
                    } else {
                        Image(systemName: isPracticing ? "pause.fill" : "play.fill").font(.system(size: 16, weight: .bold))
                        Text(isPracticing ? "PAUSE SESSION" : "START PRACTICE").font(.system(size: 14, weight: .black))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isDone ? Color.green : (isPracticing ? Color.orange : AppTheme.primaryPurple))
                .cornerRadius(28)
                .shadow(color: (isDone ? Color.green : (isPracticing ? Color.orange : AppTheme.primaryPurple)).opacity(0.3), radius: 10, y: 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, getSafeAreaBottom() > 0 ? getSafeAreaBottom() : 20)
        .background(LinearGradient(colors: [.white.opacity(0), .white, .white], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }
    
    private var completionOverlay: some View {
        Group {
            if showCompletionCelebration {
                ZStack {
                    Color.black.opacity(0.92).ignoresSafeArea()
                    VStack(spacing: 30) {
                        ZStack {
                            Circle().fill(Color.green.opacity(0.1)).frame(width: 120, height: 120)
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 60)).foregroundColor(.green)
                        }
                        
                        Text("Session Complete!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 12) {
                            Text("GREAT JOB!")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                            Text("You burned \(tracker.calculateCalories()) calories today!")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 10)
                        
                        Button(action: { dismiss() }) {
                            Text("CONTINUE").font(.system(size: 16, weight: .black)).foregroundColor(.white)
                                .padding(.horizontal, 50).padding(.vertical, 18)
                                .background(AppTheme.primaryPurple)
                                .cornerRadius(20)
                        }
                        .padding(.top, 20)
                    }
                    .padding(30)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func getSafeAreaBottom() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return keyWindow?.safeAreaInsets.bottom ?? 0
    }
    
    private func finishSession() {
        isPracticing = false
        tracker.stopSession()
        
        let completion = min(100.0, Double(tracker.activeSeconds) / Double(max(1, style.totalDuration)) * 100.0)
        
        // Log to ActivityManager if we have any active seconds
        if tracker.activeSeconds > 0 {
            let status = tracker.calculateStatus()
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
            
            if status == .completed || completion >= 95.0 {
                withAnimation {
                    showCompletionCelebration = true
                }
            }
        }
    }
}

// MARK: - Mini Helper Views

struct MiniStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10)).foregroundColor(color)
            Text(value).font(.system(size: 10, weight: .black)).foregroundColor(AppTheme.primaryPurple)
            Text(label).font(.system(size: 6, weight: .bold)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 7, weight: .black))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .kerning(0.5)
            }
            
            Text(value)
                .font(.system(size: 13, weight: .black))
                .foregroundColor(AppTheme.primaryPurple)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(.gray.opacity(0.6))
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(12)
        .frame(width: 110, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.05), lineWidth: 1))
    }
}
