import SwiftUI

struct FocusCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let videoURL: String
    
    @State private var showVideo = false
    
    var body: some View {
        Button(action: {
            showVideo = true
        }) {
            ZStack(alignment: .bottomLeading) {
                // Background Image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                
                // Darker Gradient for text readability
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.8),
                        .black.opacity(0.2),
                        .clear
                    ]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text(subtitle)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .kerning(1)
                }
                .padding(15)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
        .sheet(isPresented: $showVideo) {
            FocusDetailContentView(title: title, subtitle: subtitle, imageName: imageName)
        }
    }
}

struct FocusDetailContentView: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let subtitle: String
    let imageName: String
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Image
                    ZStack(alignment: .topTrailing) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                            .overlay(Color.black.opacity(0.3))
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                        .padding(20)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(subtitle)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
                                .kerning(2)
                            
                            Text(title)
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(AppTheme.primaryPurple)
                        }
                        
                        // Dynamic Content Based on Title
                        if title == "Flexibility" {
                            FlexibilityContent()
                        } else if title == "Strength" {
                            StrengthContent()
                        } else if title == "Breathing" {
                            BreathingContent()
                        } else if title == "Meditation" {
                            MeditationContent()
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

// MARK: - Specialized Content Views

struct FlexibilityContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Why Flexibility Matters")
                .font(.title2).bold().foregroundColor(AppTheme.primaryPurple)
            
            Text("Flexibility is not just about touching your toes; it's about unlocking your body's full range of motion. Regular stretching lengthens muscle tissue, preventing injuries and reducing the daily wear and tear on your joints.")
                .font(.body).foregroundColor(.gray).lineSpacing(6)
            
            InfoCard(icon: "figure.walk", title: "Injury Prevention", text: "Supple muscles act as shock absorbers, protecting your tendons and ligaments during sudden movements.")
            InfoCard(icon: "arrow.up.left.and.arrow.down.right", title: "Posture Correction", text: "Tight chest and shoulder muscles pull you into a slump. Stretching releases this tension, naturally improving posture.")
            InfoCard(icon: "drop.fill", title: "Better Circulation", text: "Deep stretching increases blood flow to your muscles, aiding in recovery and reducing soreness.")
        }
    }
}

struct StrengthContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("The Power of Core Strength")
                .font(.title2).bold().foregroundColor(AppTheme.primaryPurple)
            
            Text("Yoga strength isn't built with weights; it's built by conquering gravity. Developing functional strength through bodyweight resistance creates lean muscle mass, boosts metabolism, and stabilizes your entire skeletal structure.")
                .font(.body).foregroundColor(.gray).lineSpacing(6)
            
            InfoCard(icon: "bolt.fill", title: "Metabolic Boost", text: "Holding challenging poses builds dense muscle fibers, which burn more calories even while you rest.")
            InfoCard(icon: "shield.fill", title: "Spinal Armor", text: "A strong core acts like an internal corset, supporting your lower back and mitigating chronic pain.")
            InfoCard(icon: "figure.stand", title: "Bone Density", text: "Weight-bearing poses like Downward Dog stimulate bone growth, protecting against osteoporosis.")
        }
    }
}

struct BreathingContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("The Science of Pranayama")
                .font(.title2).bold().foregroundColor(AppTheme.primaryPurple)
            
            Text("Your breath is the remote control to your nervous system. By consciously altering the rhythm and depth of your breathing (Pranayama), you can immediately shift your body from a state of stress to a state of profound calm.")
                .font(.body).foregroundColor(.gray).lineSpacing(6)
            
            InfoCard(icon: "lungs.fill", title: "Oxygen Efficiency", text: "Deep diaphragmatic breathing trains your lungs to extract more oxygen per breath, boosting cellular energy.")
            InfoCard(icon: "waveform.path.ecg", title: "Heart Rate Variability", text: "Slow exhalations stimulate the Vagus nerve, naturally lowering your heart rate and blood pressure.")
            InfoCard(icon: "brain.head.profile", title: "Cortisol Reduction", text: "Conscious breathing halts the body's fight-or-flight response, drastically reducing stress hormones.")
        }
    }
}

struct MeditationContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Mastering the Mind")
                .font(.title2).bold().foregroundColor(AppTheme.primaryPurple)
            
            Text("Meditation is the ultimate exercise for your brain. It is the practice of focused attention, training your mind to remain present rather than dwelling on the past or worrying about the future.")
                .font(.body).foregroundColor(.gray).lineSpacing(6)
            
            InfoCard(icon: "eye.fill", title: "Enhanced Focus", text: "Regular meditation thickens the prefrontal cortex, the area of the brain responsible for concentration and decision-making.")
            InfoCard(icon: "cloud.sun.fill", title: "Emotional Resilience", text: "By observing thoughts without attachment, you learn to respond to emotional triggers rather than reacting impulsively.")
            InfoCard(icon: "moon.fill", title: "Restorative Sleep", text: "Calming the mind before bed promotes deep, uninterrupted REM sleep, essential for cognitive repair.")
        }
    }
}

// MARK: - Helper UI Components

struct InfoCard: View {
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(LinearGradient(colors: [AppTheme.primaryPurple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
}
