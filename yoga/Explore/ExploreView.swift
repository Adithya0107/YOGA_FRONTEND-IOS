import SwiftUI

struct ExploreView: View {
    @State private var selectedYogaStyle: YogaStyle?
    @State private var sessionStartStyle: YogaStyle?
    @State private var practiceSession: (style: YogaStyle, startIndex: Int)?
    
    // User's experience level from storage
    @AppStorage("userExperience") private var userExperience: String = "Beginner"
    
    // Curated Yoga Styles with High-Quality YouTube Links
    private var filteredStyles: [YogaStyle] {
        let level = userExperience.capitalized
        if level == "Intermediate" {
            return intermediateStyles
        } else if level == "Advanced" {
            return advancedStyles
        } else {
            return beginnerStyles
        }
    }
    
    private var levelTitle: String {
        userExperience.uppercased()
    }

    private let beginnerStyles = [
        YogaStyle(name: "Morning Weight Loss", category: "Weight Loss", level: .beginner, bgColor: Color(red: 26/255, green: 32/255, blue: 44/255), imageName: "lose_weight_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Sun Salutation A", description: "Wakes up every muscle in your body.", iconName: "sun.max", duration: 300, imageName: "pose_sun_salut"),
            YogaPose(stepNumber: 2, title: "Mountain Pose", description: "Connect with your breath and center.", iconName: "figure.stand", duration: 60, imageName: "pose_tree"),
            YogaPose(stepNumber: 3, title: "Knee-to-Chest Plank", description: "Gentle core engagement.", iconName: "bolt.fill", duration: 30, imageName: "pose_high_plank")
        ], videoURL: "https://drive.google.com/file/d/1CiJ6OinOB4G9LUG3ZkXaC8subZXgQM2E/view?usp=drivesdk"),
        
        YogaStyle(name: "Foundation Strength", category: "Muscle Gain", level: .beginner, bgColor: AppTheme.primaryPurple, imageName: "pose_warrior_1", poses: [
            YogaPose(stepNumber: 1, title: "Warrior I", description: "Build strong legs and focus.", iconName: "figure.walk", duration: 60, imageName: "pose_warrior_1"),
            YogaPose(stepNumber: 2, title: "Chair Pose", description: "Stoke the internal fire in your legs.", iconName: "figure.walk", duration: 60, imageName: "pose_warrior_2"),
            YogaPose(stepNumber: 3, title: "Baby Cobra", description: "Strengthen your back safely.", iconName: "figure.curling", duration: 45, imageName: "pose_wild_thing")
        ], videoURL: "https://drive.google.com/file/d/1NnQLYTBl3C9t0NkAEXcqZPj0VFC8hJZo/view?usp=drivesdk"),
        
        YogaStyle(name: "Gentle Flexibility", category: "Flexibility", level: .beginner, bgColor: Color.green.opacity(0.8), imageName: "pose_butterfly", poses: [
            YogaPose(stepNumber: 1, title: "Cat-Cow Flow", description: "Softens the spine and neck.", iconName: "figure.curling", duration: 120, imageName: "pose_seated_twist"),
            YogaPose(stepNumber: 2, title: "Wide-Legged Child's Pose", description: "Deep hip release and surrender.", iconName: "heart.fill", duration: 180, imageName: "pose_childs_pose"),
            YogaPose(stepNumber: 3, title: "Forward Fold", description: "Lengthen your hamstrings.", iconName: "figure.walk", duration: 90, imageName: "pose_butterfly")
        ], videoURL: "https://drive.google.com/file/d/1T21K7CixthBs9J5F_fLAga2yueuHjTFo/view?usp=drivesdk"),
        
        YogaStyle(name: "Evening Zen", category: "Stress Relief", level: .beginner, bgColor: Color.blue.opacity(0.7), imageName: "pose_childs_pose", poses: [
            YogaPose(stepNumber: 1, title: "Neck & Shoulder Release", description: "Drop the weight of the day.", iconName: "heart.fill", duration: 120),
            YogaPose(stepNumber: 2, title: "Reclined Bound Angle", description: "Passive opening for inner peace.", iconName: "heart.fill", duration: 300),
            YogaPose(stepNumber: 3, title: "Equal Breath", description: "Balance your nervous system.", iconName: "wind", duration: 180)
        ], videoURL: "https://drive.google.com/file/d/1QvLRSotpOiCH3D-wUemnqSPs6abXBusZ/view?usp=drivesdk"),
        
        YogaStyle(name: "Pranayama Basics", category: "Breathing", level: .beginner, bgColor: Color(red: 108/255, green: 71/255, blue: 255/255).opacity(0.85), imageName: "lazy_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Belly Breathing", description: "Deep diaphragmatic expansion.", iconName: "wind", duration: 180),
            YogaPose(stepNumber: 2, title: "Ujjayi Introduction", description: "The victorious warming breath.", iconName: "wind", duration: 120)
        ], videoURL: "https://drive.google.com/file/d/1ppW-d5X-0evOcBRZz1MrWOE74zq-POAz/view?usp=drivesdk")
    ]
    
    private let intermediateStyles = [
        YogaStyle(name: "Power Vinyasa Flow", category: "Weight Loss", level: .intermediate, bgColor: Color(red: 219/255, green: 144/255, blue: 112/255), imageName: "classic_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Full Sun Salutation B", description: "Dynamic aerobic flow.", iconName: "bolt.fill", duration: 480, imageName: "pose_sun_salut"),
            YogaPose(stepNumber: 2, title: "Warrior III Balance", description: "Single leg stabilization.", iconName: "figure.walk", duration: 60, imageName: "pose_warrior_3"),
            YogaPose(stepNumber: 3, title: "Side Plank Pulses", description: "Sculpt the obliques.", iconName: "bolt.fill", duration: 60, imageName: "pose_forearm_plank")
        ], videoURL: "https://drive.google.com/file/d/1kpGopYGwHxQpx83Ketpm_lvUj8yeieSu/view?usp=drivesdk"),
        
        YogaStyle(name: "Core & Balance Lab", category: "Muscle Gain", level: .intermediate, bgColor: Color.orange.opacity(0.85), imageName: "pose_warrior_2", poses: [
            YogaPose(stepNumber: 1, title: "Dolphin Pose", description: "Shoulder endurance build.", iconName: "figure.walk", duration: 90, imageName: "pose_downward_dog"),
            YogaPose(stepNumber: 2, title: "Navasana Hold", description: "Define your mid-section.", iconName: "figure.walk", duration: 90, imageName: "pose_boat"),
            YogaPose(stepNumber: 3, title: "L-Sit Prep", description: "Maximal arm recruitment.", iconName: "figure.walk", duration: 45)
        ], videoURL: "https://drive.google.com/file/d/1QvLRSotpOiCH3D-wUemnqSPs6abXBusZ/view?usp=drivesdk"),
        
        YogaStyle(name: "Flow & Lengthen", category: "Flexibility", level: .intermediate, bgColor: Color(red: 255/255, green: 111/255, blue: 97/255).opacity(0.9), imageName: "womens_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Pigeon Variations", description: "Deep outer hip opening.", iconName: "figure.curling", duration: 180),
            YogaPose(stepNumber: 2, title: "Lizard Lunge", description: "Active lengthening for hamstrings.", iconName: "figure.curling", duration: 120),
            YogaPose(stepNumber: 3, title: "Wide Leg Fold", description: "Gravity-assisted decompression.", iconName: "figure.curling", duration: 90)
        ], videoURL: "https://drive.google.com/file/d/1fXbMVcUUgMq4K1lpWmrRFy38XhxT23iX/view?usp=drivesdk"),
        
        YogaStyle(name: "Inner Harmonic Yoga", category: "Stress Relief", level: .intermediate, bgColor: Color.teal, imageName: "pose_intermediate_relief", poses: [
            YogaPose(stepNumber: 1, title: "Garudasana Arms", description: "Release deep shoulder knots.", iconName: "heart.fill", duration: 60),
            YogaPose(stepNumber: 2, title: "Supine Twist", description: "Rinse and reset the spine.", iconName: "heart.fill", duration: 180),
            YogaPose(stepNumber: 3, title: "Legs-Up-The-Wall", description: "Instant parasympathetic reset.", iconName: "heart.fill", duration: 300)
        ], videoURL: "https://drive.google.com/file/d/1gyS-zxUysZ-OVD0Q94GLiCTYUemOJiuM/view?usp=drivesdk"),
        
        YogaStyle(name: "Active Breath Mastery", category: "Breathing", level: .intermediate, bgColor: Color.indigo.opacity(0.8), imageName: "lazy_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Alternate Nostril", description: "Nadi Shodhana for balance.", iconName: "wind", duration: 300),
            YogaPose(stepNumber: 2, title: "Kapalabhati", description: "Skull-shining breath detox.", iconName: "wind", duration: 120)
        ], videoURL: "https://drive.google.com/file/d/1BUba8mjqXV-3QfMlTim2JyH4G18kGQen/view?usp=drivesdk")
    ]
    
    private let advancedStyles = [
        YogaStyle(name: "Metabolic HIIT Yoga", category: "Weight Loss", level: .advanced, bgColor: Color(red: 65/255, green: 182/255, blue: 255/255), imageName: "wall_pilates", poses: [
            YogaPose(stepNumber: 1, title: "Handstand Kickups", description: "Explosive metabolism boost.", iconName: "bolt.fill", duration: 180),
            YogaPose(stepNumber: 2, title: "Chaturanga Drills", description: "Upper body endurance test.", iconName: "bolt.fill", duration: 300),
            YogaPose(stepNumber: 3, title: "Jump Throughs", description: "High-intensity cardio flow.", iconName: "bolt.fill", duration: 120)
        ], videoURL: "https://drive.google.com/file/d/1ntlkiWYpGwP3sXNFrVCuY_DSxP7bWVe_/view?usp=drivesdk"),
        
        YogaStyle(name: "Advanced Arm Balances", category: "Muscle Gain", level: .advanced, bgColor: Color(red: 30/255, green: 40/255, blue: 50/255), imageName: "mens_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Crow-to-Plank", description: "Precision core and arm power.", iconName: "figure.walk", duration: 120),
            YogaPose(stepNumber: 2, title: "Astavakrasana", description: "Complex lateral strength.", iconName: "figure.walk", duration: 60),
            YogaPose(stepNumber: 3, title: "Pincha Mayurasana", description: "Maximum vertical line hold.", iconName: "figure.walk", duration: 90)
        ], videoURL: "https://drive.google.com/file/d/1SC7OFBaESJNqEbTpOa34Xkk1HZ_fHmLh/view?usp=drivesdk"),
        
        YogaStyle(name: "Full Body Alchemy", category: "Flexibility", level: .advanced, bgColor: Color.pink.opacity(0.7), imageName: "pose_butterfly", poses: [
            YogaPose(stepNumber: 1, title: "King Pigeon Full Bind", description: "Elite level backbend.", iconName: "figure.curling", duration: 120),
            YogaPose(stepNumber: 2, title: "Full Monkey Pose", description: "Deepest possible split hold.", iconName: "figure.curling", duration: 180),
            YogaPose(stepNumber: 3, title: "Forearm Hollow Back", description: "Advanced spinal reach.", iconName: "figure.curling", duration: 60)
        ], videoURL: "https://drive.google.com/file/d/1Grz2n0TneGYl2R2htn_ugB4IZYhehzzk/view?usp=drivesdk"),
        
        YogaStyle(name: "Meditation in Motion", category: "Stress Relief", level: .advanced, bgColor: Color.cyan.opacity(0.8), imageName: "pose_advanced_relief", poses: [
            YogaPose(stepNumber: 1, title: "Headstand Meditation", description: "Ultimate concentration shift.", iconName: "heart.fill", duration: 300),
            YogaPose(stepNumber: 2, title: "Trataka Steady Gaze", description: "Rewire your mental focus.", iconName: "heart.fill", duration: 300),
            YogaPose(stepNumber: 3, title: "Yoga Nidra Seal", description: "Complete psychic rest.", iconName: "moon.stars", duration: 600)
        ], videoURL: "https://drive.google.com/file/d/1wvH_6juWJqw9swPVSPPBr6RFv9whObkl/view?usp=drivesdk"),
        
        YogaStyle(name: "Vital Energy Unlock", category: "Breathing", level: .advanced, bgColor: Color.purple.opacity(0.9), imageName: "lazy_yoga", poses: [
            YogaPose(stepNumber: 1, title: "Bellows Breath Flow", description: "Bhastrika mastery.", iconName: "wind", duration: 180),
            YogaPose(stepNumber: 2, title: "Bandha Introduction", description: "Energy locks for core power.", iconName: "wind", duration: 120)
        ], videoURL: "https://drive.google.com/file/d/1tYdJ8kELN3qK1itLfip8Dbe1w6Nx7ZxS/view?usp=drivesdk")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 250/255, blue: 252/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // TOP BAR Pinned
                LiquidHeaderView(title: "Explore")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Hidden navigation link for Push
                        if let style = selectedYogaStyle {
                            NavigationLink(
                                destination: EnhancedVideoPlayerView(style: style),
                                tag: style.id,
                                selection: Binding(
                                    get: { selectedYogaStyle?.id },
                                    set: { if $0 == nil { selectedYogaStyle = nil } }
                                )
                            ) { EmptyView() }
                        }
                    
                    // LEVEL-BASED YOGA STYLES
                    VStack(alignment: .leading, spacing: 25) {
                        if userExperience.capitalized == "All" {
                            levelSection(title: "BEGINNER", subtitle: nil, styles: beginnerStyles)
                            levelSection(title: "INTERMEDIATE", subtitle: nil, styles: intermediateStyles)
                            levelSection(title: "ADVANCED", subtitle: nil, styles: advancedStyles)
                        } else {
                            levelSection(title: levelTitle, subtitle: "FOR YOU", styles: filteredStyles)
                        }
                    }
                    
                    // FOCUS AREA
                    VStack(alignment: .leading, spacing: 15) {
                        Text("FOCUS AREA")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
                            .kerning(1.5)
                            .padding(.horizontal, 24)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)], spacing: 15) {
                            FocusCard(title: "Flexibility", subtitle: "STRETCH & EXPAND", imageName: "focus_flexibility", videoURL: "https://drive.google.com/file/d/1T21K7CixthBs9J5F_fLAga2yueuHjTFo/view")
                            FocusCard(title: "Strength", subtitle: "POWER & CORE", imageName: "focus_strength", videoURL: "https://drive.google.com/file/d/1NnQLYTBl3C9t0NkAEXcqZPj0VFC8hJZo/view")
                            FocusCard(title: "Breathing", subtitle: "BREATH & FLOW", imageName: "focus_breathing", videoURL: "https://drive.google.com/file/d/1ppW-d5X-0evOcBRZz1MrWOE74zq-POAz/view")
                            FocusCard(title: "Meditation", subtitle: "MIND & PEACE", imageName: "focus_meditation", videoURL: "https://drive.google.com/file/d/1wvH_6juWJqw9swPVSPPBr6RFv9whObkl/view")
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // FEATURED TODAY (Also filtered by level where possible)
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("RECOMMENDED")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(AppTheme.primaryPurple.opacity(0.8))
                                .kerning(1.5)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 15) {
                            ForEach(getRecommendedClasses(), id: \.title) { item in
                                FeaturedClassCard(title: item.title, instructor: item.instructor, time: item.time, level: item.level, videoURL: item.videoURL, imageName: item.imageName, descriptionText: item.description)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
        }
    }
    .fullScreenCover(item: Binding(
            get: { sessionStartStyle },
            set: { if $0 == nil { sessionStartStyle = nil } }
        )) { style in
            EnhancedVideoPlayerView(style: style)
        }
        .fullScreenCover(item: Binding(
            get: { practiceSession != nil ? IdentifiablePractice(style: practiceSession!.style, startIndex: practiceSession!.startIndex) : nil },
            set: { if $0 == nil { practiceSession = nil } }
        )) { session in
            PracticeDetailView(style: session.style, currentIndex: session.startIndex)
        }
    }
    
    // Helper to get recommended classes based on level
    private func getRecommendedClasses() -> [RecommendedItem] {
        let level = userExperience.capitalized
        
        let allItems = [
            RecommendedItem(title: "Vinyasa Flow", instructor: "MAYA ZEN", time: "30 MIN", level: "Beginner", videoURL: "https://drive.google.com/file/d/1kpGopYGwHxQpx83Ketpm_lvUj8yeieSu/view?usp=drivesdk", imageName: "sparkles", description: "A dynamic practice that seamlessly links breath with motion, building heat, cardiovascular endurance, and fluid transitions."),
            RecommendedItem(title: "Hatha Yoga", instructor: "SARAH B.", time: "45 MIN", level: "Beginner", videoURL: "https://drive.google.com/file/d/157ViROKwiFTJXTBD_35ncqNLCR5RvQj4/view?usp=drivesdk", imageName: "sun.max.fill", description: "A gentle, slower-paced practice focused on foundational poses and holding postures to build solid strength and mindfulness."),
            RecommendedItem(title: "Power Yoga", instructor: "KAI STRONG", time: "40 MIN", level: "Advanced", videoURL: "https://drive.google.com/file/d/1SC7OFBaESJNqEbTpOa34Xkk1HZ_fHmLh/view?usp=drivesdk", imageName: "bolt.fill", description: "An intense, fitness-based approach to Vinyasa. Builds massive internal heat, stamina, core strength, and physical resilience."),
            RecommendedItem(title: "Restorative Yoga", instructor: "LUNA SOFT", time: "60 MIN", level: "Beginner", videoURL: "https://drive.google.com/file/d/12UL49_OAIGluZsmQ0Y_9uNbke1LLkYBd/view?usp=drivesdk", imageName: "leaf.fill", description: "A profoundly restful sequence emphasizing physical relaxation and stress relief through passive, prop-supported stretching."),
            RecommendedItem(title: "Yin Yoga Relief", instructor: "ELARA M.", time: "35 MIN", level: "Intermediate", videoURL: "https://drive.google.com/file/d/13JtAsmLgX6NUyzupEd-GyWCyQ1rw-oNw/view?usp=drivesdk", imageName: "moon.fill", description: "Targets deep connective tissues like fascia, ligaments, and joints through long, passive holds to significantly improve flexibility."),
            RecommendedItem(title: "Ashtanga Basic", instructor: "JASON P.", time: "50 MIN", level: "Advanced", videoURL: "https://drive.google.com/file/d/1ntlkiWYpGwP3sXNFrVCuY_DSxP7bWVe_/view", imageName: "figure.walk", description: "A structured, highly energetic practice strictly following a specific set sequence of postures to purify the nervous system."),
            RecommendedItem(title: "Kundalini Rising", instructor: "ANAYA G.", time: "30 MIN", level: "Intermediate", videoURL: "https://drive.google.com/file/d/1gyS-zxUysZ-OVD0Q94GLiCTYUemOJiuM/view", imageName: "wind", description: "An uplifting blend of spiritual and physical exercises utilizing intense breathwork, repetitive movement, and deep meditation.")
        ]
        
        // Return 5 items: priority to matching level, then others
        let matching = allItems.filter { $0.level == level }
        let others = allItems.filter { $0.level != level }
        
        return Array((matching + others).prefix(5))
    }

    @ViewBuilder
    private func levelSection(title: String, subtitle: String?, styles: [YogaStyle]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(AppTheme.primaryPurple)
                    .kerning(1.5)
                
                if let subtitleText = subtitle {
                    Text(subtitleText)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .kerning(1.5)
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Spacer().frame(width: 9)
                    ForEach(styles) { style in
                        YogaStyleCard(style: style, action: {
                            selectedYogaStyle = style
                        }, onVideoPlay: {
                            sessionStartStyle = style
                        })
                    }
                    Spacer().frame(width: 9)
                }
            }
        }
    }
}

struct RecommendedItem {
    let title: String
    let instructor: String
    let time: String
    let level: String
    let videoURL: String
    let imageName: String
    let description: String
}

