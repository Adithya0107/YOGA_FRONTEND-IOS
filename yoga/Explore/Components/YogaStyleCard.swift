import SwiftUI

struct YogaStyleCard: View {
    let style: YogaStyle
    let action: () -> Void
    var onVideoPlay: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Background Card
            RoundedRectangle(cornerRadius: 30)
                .fill(style.bgColor)
                .frame(width: 340, height: 160)
            
            HStack(spacing: 0) {
                // Left Text Side
                VStack(alignment: .leading, spacing: 12) {
                    Text(style.name)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 150, alignment: .leading)
                    
                    Button(action: action) {
                        Text("VIEW STEPS")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
                .padding(.leading, 25)
                
                Spacer()
                
                // Right Image Side
                ZStack(alignment: .center) {
                    Image(style.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    if let videoURL = style.videoURL {
                        Button(action: {
                            if let onVideoPlay = onVideoPlay {
                                onVideoPlay()
                            } else {
                                if let url = URL(string: videoURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.black.opacity(0.15), radius: 10)
                                
                                Image(systemName: "play.fill")
                                    .foregroundColor(style.bgColor)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                }
                .padding(.trailing, 0) // Fits flush to the right
            }
            .frame(width: 340, height: 160)
        }
        .shadow(color: style.bgColor.opacity(0.2), radius: 12, x: 0, y: 8)
    }
}
