import SwiftUI
import Combine

struct YogaVideoPlayerView: View {
    @Environment(\.dismiss) var dismiss
    let style: YogaStyle
    
    @State private var isPracticing = false
    @State private var practiceSeconds = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
        return "unknown"
    }
    
    var body: some View {
        ZStack {
            Color(red: 26/255, green: 32/255, blue: 44/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                
                // Track Info Top
                VStack(spacing: 12) {
                    Text(style.name)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Yoga Fitness Tracker")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 170/255, green: 130/255, blue: 255/255))
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.gray)
                            Text("\(style.totalDuration / 60) MINS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text(style.level.rawValue.uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.vertical, 24)
                
                // Center Video Player
                YouTubePlayerView(videoURL: style.videoURL ?? "", isPlaying: $isPracticing) { state in
                    DispatchQueue.main.async {
                        if state == 1 { // PLAYING
                            isPracticing = true
                        } else if state == 2 || state == 0 { // PAUSED or ENDED
                            isPracticing = false
                        }
                    }
                }
                    .frame(height: 240)
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .shadow(color: Color.black.opacity(0.3), radius: 15, y: 10)
                
                Spacer()
                
                // Timer Text
                VStack(spacing: 8) {
                    Text("PRACTICE TIMER")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray.opacity(0.8))
                        .kerning(1.5)
                        
                    Text(timeString(practiceSeconds))
                        .font(.system(size: 56, weight: .black, design: .monospaced))
                        .foregroundColor(isPracticing ? .green : .white)
                }
                .padding(.bottom, 40)
                
                // Bottom Controls
                HStack(spacing: 20) {
                    Button(action: {
                        isPracticing.toggle()
                    }) {
                        Text(isPracticing ? "PAUSE SESSION" : "START PRACTICE")
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(isPracticing ? Color.orange : Color(red: 124/255, green: 58/255, blue: 237/255))
                            .cornerRadius(16)
                            .shadow(color: (isPracticing ? Color.orange : Color(red: 124/255, green: 58/255, blue: 237/255)).opacity(0.3), radius: 10, y: 5)
                    }
                    
                    Button(action: {
                        completeSession()
                    }) {
                        Text("COMPLETE SESSION")
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.green)
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .onReceive(timer) { _ in
            if isPracticing {
                practiceSeconds += 1
            }
        }
        .navigationBarHidden(true)
    }
    
    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func completeSession() {
        isPracticing = false
        
        // Save to Flask API
        guard let url = URL(string: "\(AppTheme.yogaBaseURL)/save_session") else { return }
        let userId = UserDefaults.standard.integer(forKey: "user_id") > 0 ? UserDefaults.standard.integer(forKey: "user_id") : 1
        
        // Map to Flask backend expectations
        let completionPercent = Double(practiceSeconds) / Double(max(1, style.totalDuration)) * 100
        let caloriesBurned = Int((Double(practiceSeconds) / 60.0) * 5.5) // Approx 5.5 cal/min
        
        let body: [String: Any] = [
            "user_id": userId,
            "style_name": style.name,
            "level": style.level.rawValue,
            "total_duration": style.totalDuration,
            "actual_duration": practiceSeconds,
            "completion_percentage": min(100.0, completionPercent),
            "status": "completed",
            "calories": caloriesBurned
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                dismiss()
            }
        }.resume()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
