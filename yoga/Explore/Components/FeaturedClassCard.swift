import SwiftUI

struct FeaturedClassCard: View {
    let title: String
    let instructor: String
    let time: String
    let level: String
    let videoURL: String
    let imageName: String
    var descriptionText: String? = nil
    
    @State private var showVideo = false
    @State private var isFullScreen = false
    @State private var isPlaying = false
    
    var body: some View {
        Button(action: {
            showVideo = true
        }) {
            HStack(spacing: 16) {
                // Play Button Area with Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryPurple.opacity(0.15), AppTheme.primaryPurple.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.primaryPurple)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(instructor.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(AppTheme.primaryPurple.opacity(0.6))
                            .kerning(1)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        
                        Text(time)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    
                    HStack {
                        Text(level.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(8)
                        
                        Spacer()
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.2))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.03), radius: 15, x: 0, y: 8)
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.05), lineWidth: 1))
        }
        .fullScreenCover(isPresented: $showVideo) {
            ZStack {
                if isFullScreen {
                    Color.black.ignoresSafeArea()
                    
                    YouTubePlayerView(videoURL: videoURL, isPlaying: $isPlaying, cornerRadius: 0, shadowRadius: 0)
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Button(action: { withAnimation { isFullScreen = false } }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                            .padding(.top, 60)
                            .padding(.leading, 20)
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    Color.white.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text(title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(AppTheme.primaryPurple)
                            Spacer()
                            Button(action: { showVideo = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppTheme.primaryPurple.opacity(0.6))
                            }
                        }
                        .padding(24)
                        .padding(.top, 40)
                        
                        // Video Player Area
                        ZStack(alignment: .bottomTrailing) {
                            YouTubePlayerView(videoURL: videoURL, isPlaying: $isPlaying, cornerRadius: 24, shadowRadius: 0)
                                .frame(height: 300)
                                .padding(.horizontal, 16)
                                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                            
                            // Full Screen Toggle
                            Button(action: { withAnimation { isFullScreen = true } }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding(28)
                        }
                        
                        ScrollView {
                            // Information Section
                            if let desc = descriptionText {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("About This Practice")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                                    
                                    Text(desc)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255).opacity(0.7))
                                        .lineSpacing(6)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Begin Button
                            Button(action: { showVideo = false }) {
                                Text("BEGIN SESSION")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(AppTheme.primaryPurple)
                                    .cornerRadius(20)
                                    .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 10, y: 5)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                isPlaying = true
            }
        }
    }
}
