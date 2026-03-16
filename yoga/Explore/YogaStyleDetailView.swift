import SwiftUI

struct YogaStyleDetailView: View {
    @Environment(\.dismiss) var dismiss
    let style: YogaStyle
    @State private var showSessionStart = false
    @State private var practiceSession: (style: YogaStyle, startIndex: Int)?
    @State private var showVideo = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5))
                    }
                    
                    Text(style.name)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                        .padding(.leading, 10)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    // Video Overview Button
                    if style.videoURL != nil && !style.videoURL!.isEmpty {
                        Button(action: { showVideo = true }) {
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.primaryPurple)
                                .padding(10)
                                .background(AppTheme.primaryPurple.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                    }
                    
                    // Level badge
                    Text(style.level.rawValue.uppercased())
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .kerning(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(levelColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                .padding(.bottom, 15)
                
                // Session overview strip
                HStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(style.poses.count)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryPurple)
                        Text("POSES")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.gray.opacity(0.6))
                            .kerning(1)
                    }
                    
                    Divider().frame(height: 30).padding(.horizontal, 20)
                    
                    VStack(spacing: 2) {
                        Text(durationString(style.totalDuration))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryPurple)
                        Text("DURATION")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.gray.opacity(0.6))
                            .kerning(1)
                    }
                    
                    Divider().frame(height: 30).padding(.horizontal, 20)
                    
                    VStack(spacing: 2) {
                        Text(durationString(style.level.minPracticeTime))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryPurple)
                        Text("MIN REQUIRED")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.gray.opacity(0.6))
                            .kerning(1)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(style.poses.enumerated()), id: \.offset) { index, pose in
                            PoseStepCard(pose: pose) {
                                showSessionStart = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 110)
                }
            }
            
            // Floating "Begin Session" CTA
            VStack {
                Spacer()
                Button(action: { showSessionStart = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                        Text("BEGIN SESSION")
                            .font(.system(size: 15, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        LinearGradient(colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.opacity(0.8)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(20)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.35), radius: 20, y: 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        // Session start sheet
        .fullScreenCover(isPresented: $showSessionStart) {
            SessionStartView(style: style) {
                practiceSession = (style, 0)
            }
        }
        // Practice session
        .fullScreenCover(item: Binding(
            get: { practiceSession != nil ? IdentifiablePractice(style: practiceSession!.style, startIndex: practiceSession!.startIndex) : nil },
            set: { if $0 == nil { practiceSession = nil } }
        )) { session in
            PracticeDetailView(style: session.style, currentIndex: session.startIndex)
        }
        .sheet(isPresented: $showVideo) {
            VStack {
                HStack {
                    Text(style.name)
                        .font(.headline)
                    Spacer()
                    Button("Done") { showVideo = false }
                }
                .padding()
                
                YouTubePlayerView(videoURL: style.videoURL ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var levelColor: Color {
        switch style.level {
        case .beginner: return Color(red: 34/255, green: 197/255, blue: 94/255)
        case .intermediate: return Color(red: 234/255, green: 179/255, blue: 8/255)
        case .advanced: return Color(red: 239/255, green: 68/255, blue: 68/255)
        case .proAdvanced: return Color(red: 124/255, green: 58/255, blue: 237/255)
        }
    }
    
    private func durationString(_ seconds: Int) -> String {
        let mins = seconds / 60
        if mins < 60 { return "\(mins)m" }
        return "\(mins / 60)h \(mins % 60)m"
    }
}

struct IdentifiablePractice: Identifiable {
    let id = UUID()
    let style: YogaStyle
    let startIndex: Int
}

struct PoseStepCard: View {
    let pose: YogaPose
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 18) {
            // Step Number Badge
            ZStack {
                Circle()
                    .fill(AppTheme.primaryPurple)
                    .frame(width: 44, height: 44)
                Text("\(pose.stepNumber)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pose.title.uppercased())
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(AppTheme.primaryPurple)
                    .kerning(1)
                
                Text(pose.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                
                Text(poseTime(pose.duration))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(AppTheme.primaryPurple.opacity(0.4))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.08), lineWidth: 1))
    }
    
    private func poseTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m == 0 { return "\(s) sec" }
        if s == 0 { return "\(m) min" }
        return "\(m) min \(s) sec"
    }
}
