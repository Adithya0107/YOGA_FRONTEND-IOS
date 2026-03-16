import SwiftUI
import Combine

enum AuthStep: Hashable {
    case personalizedForYou
    case createAccount
    case onboardingSurvey
    case creatingPlan
    case signIn
    case forgotPassword
    case verifyOTP
    case resetPasswordVerifyOTP
    case resetPasswordNewPassword
}



struct AuthenticationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep: AuthStep
    @State private var navigationDirection: Edge = .trailing
    
    init(initialStep: AuthStep = .personalizedForYou) {
        _currentStep = State(initialValue: initialStep)
    }
    @State private var showResetConfirmation = false
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("userId") private var storedUserId: Int = 0
    @AppStorage("userFullName") private var storedFullName: String = ""
    @AppStorage("userEmail") private var storedEmail: String = ""
    
    // Form State
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var rememberMe = false
    @State private var forgotPasswordEmail = ""
    
    // API State
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var successMessage = ""
    
    
    // Password validation state
    @State private var passwordChecks: [String: Bool] = [
        "exactLength": false, "hasUppercase": false, "hasLowercase": false,
        "hasNumber": false, "hasSpecial": false
    ]
    @State private var isPasswordValid = false
    
    private func updatePasswordChecks(_ pass: String) {
        passwordChecks["exactLength"] = pass.count >= 8
        passwordChecks["hasUppercase"] = pass.range(of: "[A-Z]", options: .regularExpression) != nil
        passwordChecks["hasLowercase"] = pass.range(of: "[a-z]", options: .regularExpression) != nil
        passwordChecks["hasNumber"] = pass.range(of: "[0-9]", options: .regularExpression) != nil
        passwordChecks["hasSpecial"] = pass.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~]", options: .regularExpression) != nil
        
        isPasswordValid = !passwordChecks.values.contains(false)
    }

    private func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Forgot password flow state
    @State private var resetOTPDigits: [String] = Array(repeating: "", count: 6)
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var isNewPasswordVisible = false
    @State private var newPasswordChecks: [String: Bool] = [
        "exactLength": false, "hasUppercase": false, "hasLowercase": false,
        "hasNumber": false, "hasSpecial": false
    ]
    @State private var isNewPasswordValid = false

    private func updateNewPasswordChecks(_ pass: String) {
        newPasswordChecks["exactLength"] = pass.count >= 8
        newPasswordChecks["hasUppercase"] = pass.range(of: "[A-Z]", options: .regularExpression) != nil
        newPasswordChecks["hasLowercase"] = pass.range(of: "[a-z]", options: .regularExpression) != nil
        newPasswordChecks["hasNumber"] = pass.range(of: "[0-9]", options: .regularExpression) != nil
        newPasswordChecks["hasSpecial"] = pass.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?`~]", options: .regularExpression) != nil
        
        isNewPasswordValid = !newPasswordChecks.values.contains(false)
    }
    
    // Survey State (Using @State to ensure manual selection every time)
    @State private var surveyStep: Int = 1
    @State private var selectedAge: String = ""
    @State private var gender: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var goal: String = ""
    @State private var activityLevel: String = ""
    @State private var experience: String = ""
    @State private var focusArea: String = ""
    @State private var frequency: String = ""
    
    // Persistent Storage (Updating at the end of survey)
    @AppStorage("userAge") private var storedAge: String = ""
    @AppStorage("userGender") private var storedGender: String = ""
    @AppStorage("userHeight") private var storedHeight: String = ""
    @AppStorage("userWeight") private var storedWeight: String = ""
    @AppStorage("userGoal") private var storedGoal: String = ""
    @AppStorage("userActivityLevel") private var storedActivityLevel: String = ""
    @AppStorage("userExperience") private var storedExperience: String = ""
    @AppStorage("userFocusArea") private var storedFocusArea: String = ""
    @AppStorage("userFrequency") private var storedFrequency: String = ""
    
    // OTP State
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var resendCooldown: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let ageOptions = ["18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    let genderOptions = ["Male", "Female", "Other"]
    let goalOptions = ["Lose Weight", "Gain Muscle", "Flexibility", "Stress Relief"]
    let activityOptions = ["Sedentary", "Lightly Active", "Active", "Very Active"]
    let experienceOptions = ["Beginner", "Intermediate", "Advanced", "All"]
    let focusOptions = ["Back Pain", "Core Strength", "Legs & Glutes", "Full Body"]
    let frequencyOptions = ["1-2 days", "3-4 days", "5-6 days", "Daily"]
    

    var body: some View {
        ZStack {
            AppTheme.neumorphicBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header (Back/Close Button)
                HStack {
                    if currentStep == .createAccount || currentStep == .signIn || currentStep == .forgotPassword || currentStep == .verifyOTP || currentStep == .resetPasswordVerifyOTP || currentStep == .resetPasswordNewPassword {
                        Spacer()
                        Button(action: { 
                            dismiss() 
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(15)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5))
                        }
                    } else {
                        Button(action: handleBackAction) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(15)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5))
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                ZStack {
                    switch currentStep {
                    case .personalizedForYou:
                        personalizedForYouView
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .createAccount:
                        createAccountView
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .onboardingSurvey:
                        onboardingSurveyView
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .creatingPlan:
                        CreatingPlanWrapperView(currentStep: $currentStep, isAuthenticated: $isAuthenticated, hasAccount: $hasAccount)
                            .transition(.opacity)
                    case .signIn:
                        signInView
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .forgotPassword:
                        forgotPasswordView
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .verifyOTP:
                        verifyOTPView
                            .onReceive(timer) { _ in
                                if resendCooldown > 0 {
                                    resendCooldown -= 1
                                }
                            }
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .resetPasswordVerifyOTP:
                        resetPasswordVerifyOTPView
                            .onReceive(timer) { _ in
                                if resendCooldown > 0 { resendCooldown -= 1 }
                            }
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    case .resetPasswordNewPassword:
                        resetPasswordNewPasswordView
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: navigationDirection).combined(with: .opacity),
                                removal: AnyTransition.move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: currentStep)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(successMessage.isEmpty ? "Error" : "Success"),
                message: Text(successMessage.isEmpty ? errorMessage : successMessage),
                dismissButton: .default(Text("OK")) {
                    successMessage = ""
                    errorMessage = ""
                }
            )
        }
    }
    
    private func handleBackAction() {
        navigationDirection = .leading
        withAnimation(.easeInOut(duration: 0.4)) {
            switch currentStep {
            case .personalizedForYou:
                dismiss()
            case .createAccount:
                currentStep = .personalizedForYou
            case .verifyOTP:
                currentStep = .createAccount
            case .onboardingSurvey:
                if surveyStep > 1 {
                    surveyStep -= 1
                } else {
                    currentStep = .personalizedForYou
                }
            case .creatingPlan:
                currentStep = .onboardingSurvey
                surveyStep = 9
            case .signIn:
                currentStep = .personalizedForYou
            case .forgotPassword:
                currentStep = .signIn
            default:
                break
            }
        }
    }
    
    private var isCurrentSurveyStepValid: Bool {
        switch surveyStep {
        case 1: return !selectedAge.isEmpty
        case 2: return !gender.isEmpty
        case 3: return !height.isEmpty
        case 4: return !weight.isEmpty
        case 5: return !goal.isEmpty
        case 6: return !activityLevel.isEmpty
        case 7: return !experience.isEmpty
        case 8: return !focusArea.isEmpty
        case 9: return !frequency.isEmpty
        default: return true
        }
    }
    
    private func advanceToNextSurveyStep() {
        navigationDirection = .trailing
        if surveyStep < 9 {
            withAnimation(.easeInOut(duration: 0.4)) { surveyStep += 1 }
        } else {
            // Save all survey results to persistent storage before moving on
            saveSurveyResults()
            withAnimation(.easeInOut(duration: 0.4)) { currentStep = .creatingPlan }
        }
    }
    
    private func saveSurveyResults() {
        storedAge = selectedAge
        storedGender = gender
        storedHeight = height
        storedWeight = weight
        storedGoal = goal
        storedActivityLevel = activityLevel
        storedExperience = experience
        storedFocusArea = focusArea
        storedFrequency = frequency
        
        // Let CreatingPlanView handle the network request to ensure it doesn't get cancelled during view transitions.
    }
    
    // Removed internal sendSurveyResultsToBackend to avoid transition cancellation. It is now handled by CreatingPlanView.
    
    // MARK: - Screens

    @ViewBuilder
    private var personalizedForYouView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Personalized For You")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryPurple)
                
                Text("Discover how ZenForge helps you achieve\nyour wellness goals.")
                    .font(AppTheme.bodyFont(size: 17))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    FeatureCard(
                        title: "AI Yoga Guidance",
                        subtitle: "Smart pose detection and real-time corrections powered by AI.",
                        icon: "sparkles",
                        iconColor: AppTheme.primaryPurple,
                        iconBg: Color(red: 245/255, green: 242/255, blue: 255/255)
                    )
                    
                    FeatureCard(
                        title: "Personalized Plans",
                        subtitle: "Workouts that adapt to your body type, goals, and progress.",
                        icon: "target",
                        iconColor: Color(red: 65/255, green: 182/255, blue: 255/255),
                        iconBg: Color(red: 240/255, green: 252/255, blue: 255/255)
                    )
                    
                    FeatureCard(
                        title: "Diet Recommendations",
                        subtitle: "Smart nutrition plans to complement your physical training.",
                        icon: "leaf.fill",
                        iconColor: Color.green,
                        iconBg: Color.green.opacity(0.1),
                        picture: "Image",
                        isCustomImage: true
                    )
                    
                    FeatureCard(
                        title: "Progress Tracking",
                        subtitle: "Detailed insights and analytics of your transformation journey.",
                        icon: "chart.bar.fill",
                        iconColor: Color(red: 65/255, green: 182/255, blue: 255/255),
                        iconBg: Color(red: 240/255, green: 252/255, blue: 255/255)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 100) // Space for button
            }
            .overlay(
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation { currentStep = .createAccount }
                    }) {
                        HStack {
                            Text("Start Personalization")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(AppTheme.authGradient)
                        .cornerRadius(25)
                        .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 15, x: 0, y: 10)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [AppTheme.neumorphicBackground.opacity(0), AppTheme.neumorphicBackground]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    )
                },
                alignment: .bottom
            )
        }
    }
    
    @ViewBuilder
    private var onboardingSurveyView: some View {
        VStack(spacing: 0) {
            // Top Progress Bar - Fixed at top
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 6)
                
                Rectangle()
                    .fill(AppTheme.authGradient)
                    .frame(width: UIScreen.main.bounds.width * CGFloat(surveyStep) / 9.0, height: 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 5)
            
            // Header Info
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("PROGRESS")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 130/255, green: 90/255, blue: 255/255))
                        .kerning(1)
                    
                    HStack(spacing: 0) {
                        Text("\(surveyStep)")
                            .font(.system(size: 28, weight: .black))
                        Text("/ 9")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                }
            }
            .padding(.trailing, 28)
            .padding(.top, 10)
            
            Spacer()
            
            // Content area with stable frame to prevent jumping
            ZStack {
                Group {
                    switch surveyStep {
                    case 1: ageSelectionContentView
                    case 2: genderSelectionContentView
                    case 3: heightSelectionContentView
                    case 4: weightSelectionContentView
                    case 5: goalSelectionContentView
                    case 6: activitySelectionContentView
                    case 7: experienceSelectionContentView
                    case 8: focusSelectionContentView
                    case 9: frequencySelectionContentView
                    default: 
                        Text("Step \(surveyStep)")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: navigationDirection).combined(with: .opacity),
                    removal: .move(edge: navigationDirection == .trailing ? .leading : .trailing).combined(with: .opacity)
                ))
            }
            .animation(.easeInOut(duration: 0.45), value: surveyStep)
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Action Buttons
            HStack(spacing: 15) {
                // Next Button
                Button(action: {
                    advanceToNextSurveyStep()
                }) {
                    HStack(spacing: 8) {
                        Text("Next Step")
                            .font(.system(size: 18, weight: .bold))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(isCurrentSurveyStepValid ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(isCurrentSurveyStepValid ? AppTheme.authGradient : LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(30)
                    .shadow(color: isCurrentSurveyStepValid ? AppTheme.primaryPurple.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                }
                .disabled(!isCurrentSurveyStepValid)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
    
    @ViewBuilder
    private var ageSelectionContentView: some View {
        VStack(spacing: 50) {
            Text("How old are you?")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryPurple)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                ForEach(ageOptions, id: \.self) { option in
                    SurveySelectionItem(title: option, isSelected: selectedAge == option) {
                        selectedAge = option
                    }
                }
            }
        }
    }
    
    private var heightSelectionContentView: some View {
        VStack(spacing: 50) {
            Text("What's your height?")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 17/255, green: 24/255, blue: 39/255))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            VStack(spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    TextField("170", text: $height)
                        .keyboardType(.numberPad)
                        .font(.system(size: 75, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255)) // Dark text color
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 100)
                        .fixedSize(horizontal: true, vertical: false)
                        .onChange(of: height, perform: { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            let limited = String(filtered.prefix(3))
                            if newValue != limited {
                                height = limited
                            }
                        })
                    
                    Text("cm")
                        .font(.system(size: 75, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple.opacity(0.3))
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 3)
                    .padding(.top, 10)
                
                Text("CENTIMETERS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .padding(.top, 40)
                    .kerning(1)
            }
            .padding(.top, 40)
        }
    }
    
    private var genderSelectionContentView: some View {
        selectionContentView(title: "What's your gender?", options: genderOptions, selection: $gender)
    }
    
    private var weightSelectionContentView: some View {
        VStack(spacing: 50) {
            Text("What's your weight?")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryPurple)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            VStack(spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    TextField("70", text: $weight)
                        .keyboardType(.numberPad)
                        .font(.system(size: 75, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255)) // Dark text color
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 100)
                        .fixedSize(horizontal: true, vertical: false)
                        .onChange(of: weight, perform: { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            let limited = String(filtered.prefix(3))
                            if newValue != limited {
                                weight = limited
                            }
                        })
                    
                    Text("kg")
                        .font(.system(size: 75, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple.opacity(0.3))
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 3)
                    .padding(.top, 10)
                
                Text("KILOGRAMS")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .padding(.top, 40)
                    .kerning(1)
            }
            .padding(.top, 40)
        }
    }
    
    private var goalSelectionContentView: some View {
        selectionContentView(title: "What's your goal?", options: goalOptions, selection: $goal)
    }
    
    private var activitySelectionContentView: some View {
        selectionContentView(title: "Activity level?", options: activityOptions, selection: $activityLevel)
    }
    
    private var experienceSelectionContentView: some View {
        selectionContentView(title: "Yoga experience?", options: experienceOptions, selection: $experience)
    }
    
    private var focusSelectionContentView: some View {
        selectionContentView(title: "Focus area?", options: focusOptions, selection: $focusArea)
    }
    
    private var frequencySelectionContentView: some View {
        selectionContentView(title: "Workout frequency?", options: frequencyOptions, selection: $frequency)
    }
    
    @ViewBuilder
    private func selectionContentView(title: String, options: [String], selection: Binding<String>) -> some View {
        return VStack(spacing: 50) {
            Text(title)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryPurple)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                ForEach(options, id: \.self) { option in
                    SurveySelectionItem(title: option, isSelected: selection.wrappedValue == option) {
                        selection.wrappedValue = option
                    }
                }
            }
        }
    }
    

    @ViewBuilder
    private var createAccountView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create Account")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text("Join ZenForge and start your journey")
                        .font(AppTheme.bodyFont(size: 18))
                        .foregroundColor(Color.gray)
                }
                
                VStack(spacing: 24) {
                    NeumorphicTextField(title: "Full Name", placeholder: "Enter your name", text: $fullName, icon: "person")
                    NeumorphicTextField(title: "Phone Number", placeholder: "123-456-7890", text: $phoneNumber, icon: "phone", keyboardType: .phonePad)
                    NeumorphicTextField(title: "Email Address", placeholder: "Enter your email address", text: $email, icon: "envelope", keyboardType: .emailAddress)
                        .onChange(of: email) { newValue in
                            email = newValue.lowercased()
                        }
                    NeumorphicPasswordField(title: "Password", placeholder: "At least 8 characters", text: $password, isVisible: $isPasswordVisible)
                        .onChange(of: password) { newValue in updatePasswordChecks(newValue) }
                    
                    if !password.isEmpty && !isPasswordValid {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password must be at least 8 characters with:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red.opacity(0.8))
                            
                            HStack {
                                RequirementTag(text: "8 Chars", isValid: passwordChecks["exactLength"] ?? false)
                                RequirementTag(text: "A-Z", isValid: passwordChecks["hasUppercase"] ?? false)
                                RequirementTag(text: "a-z", isValid: passwordChecks["hasLowercase"] ?? false)
                                RequirementTag(text: "0-9", isValid: passwordChecks["hasNumber"] ?? false)
                                RequirementTag(text: "Special", isValid: passwordChecks["hasSpecial"] ?? false)
                            }
                        }
                        .padding(.horizontal, 5)
                    }

                    NeumorphicPasswordField(title: "Re-enter Password", placeholder: "••••••••", text: $confirmPassword, isVisible: $isPasswordVisible, showToggle: true)
                }
                
                VStack(spacing: 20) {
                    Button(action: { 
                        performRegistration()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(AppTheme.primaryPurple)
                        .cornerRadius(25)
                        .shadow(color: AppTheme.primaryPurple.opacity(0.35), radius: 15, x: 0, y: 10)
                    }
                    .disabled(isLoading || fullName.isEmpty || email.isEmpty || password.isEmpty || !isPasswordValid || password != confirmPassword)
                }
                .padding(.top, 10)
                
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Button(action: { withAnimation { currentStep = .signIn }}) {
                        Text("SIGN IN")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
        }
    }
    
    private func simulateSocialLogin() {
        // Simplified simulated login for AuthenticationView
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                isAuthenticated = true
                hasAccount = true
            }
        }
    }

    

    
    @ViewBuilder
    private var signInView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text("Sign in to continue your journey")
                        .font(AppTheme.bodyFont(size: 18))
                        .foregroundColor(Color.gray)
                }
                
                VStack(spacing: 24) {
                    NeumorphicTextField(title: "Email", placeholder: "Enter your email address", text: $email, icon: "envelope", keyboardType: .emailAddress)
                        .onChange(of: email) { newValue in
                            email = newValue.lowercased()
                        }
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        NeumorphicPasswordField(title: "Password", placeholder: "••••••••", text: $password, isVisible: $isPasswordVisible)
                        
                        Button(action: { withAnimation { currentStep = .forgotPassword }}) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.primaryPurple)
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    Button(action: { 
                        performLogin()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(AppTheme.authGradient)
                        .cornerRadius(25)
                        .shadow(color: AppTheme.primaryPurple.opacity(0.35), radius: 15, x: 0, y: 10)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                }
                
                HStack {
                    Spacer()
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Button(action: { withAnimation { currentStep = .createAccount }}) {
                        Text("CREATE ACCOUNT")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primaryPurple)
                            .padding(.trailing, 4)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                    Spacer()
                }
                
                
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
        }
    }

    
    @ViewBuilder
    private var verifyOTPView: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Verification")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryPurple)
                
                Text("Enter the 6-digit code sent to \(email)")
                    .font(AppTheme.bodyFont(size: 18))
                    .foregroundColor(Color.gray)
                    .lineLimit(2)
            }
            
            // OTP INPUT GRID
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $otpDigits[index])
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: index)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(AppTheme.neumorphicBackground)
                                .shadow(color: AppTheme.neumorphicShadowDark.opacity(0.1), radius: 5, x: 2, y: 2)
                        )
                        .onChange(of: otpDigits[index]) { newValue in
                            if newValue.count > 1 {
                                otpDigits[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 5 {
                                focusedField = index + 1
                            }
                        }
                }
            }
            .padding(.top, 10)
            
            VStack(spacing: 20) {
                Button(action: verifyOTP) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Verify Code")
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                        }
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(AppTheme.authGradient)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(isLoading || otpDigits.contains { $0.isEmpty })
                
                Button(action: {
                    if let url = URL(string: "googlegmail://") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        } else {
                            UIApplication.shared.open(URL(string: "https://mail.google.com")!)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.open.fill")
                        Text("Open Gmail")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppTheme.primaryPurple.opacity(0.2), lineWidth: 1.5)
                    )
                }
            }
            
            HStack {
                Text("Didn't receive it?")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                Button(action: sendOTP) {
                    Text(resendCooldown > 0 ? "Resend in \(resendCooldown)s" : "Resend OTP")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(resendCooldown > 0 ? .gray : AppTheme.primaryPurple)
                }
                .disabled(resendCooldown > 0)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .onAppear {
            focusedField = 0
        }
    }
    
    private var forgotPasswordView: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Forgot Password")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                
                Text("Enter your registered email to receive a reset code.")
                    .font(AppTheme.bodyFont(size: 18))
                    .foregroundColor(Color.gray)
                    .lineSpacing(4)
            }
            
            VStack(spacing: 24) {
                NeumorphicTextField(title: "Email Address", placeholder: "john@example.com", text: $forgotPasswordEmail, icon: "envelope", keyboardType: .emailAddress)
                    .onChange(of: forgotPasswordEmail) { newValue in
                        forgotPasswordEmail = newValue.lowercased()
                    }
                
                Button(action: { 
                    sendResetOTP()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Send Reset OTP")
                            Spacer()
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(AppTheme.authGradient)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.35), radius: 10, y: 5)
                }
                .disabled(isLoading || !isEmailValid(forgotPasswordEmail))
            }
            
            Button(action: { withAnimation { currentStep = .signIn }}) {
                HStack {
                    Spacer()
                    Text("Back to Sign In")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.gray)
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
    }
    
    private var resetPasswordVerifyOTPView: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Verification")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryPurple)
                
                Text("Enter the 6-digit code sent to \(forgotPasswordEmail)")
                    .font(AppTheme.bodyFont(size: 18))
                    .foregroundColor(Color.gray)
                    .lineLimit(2)
            }
            
            // OTP INPUT GRID
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $resetOTPDigits[index])
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: index)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(AppTheme.neumorphicBackground)
                                .shadow(color: AppTheme.neumorphicShadowDark.opacity(0.1), radius: 5, x: 2, y: 2)
                        )
                        .onChange(of: resetOTPDigits[index]) { newValue in
                            if newValue.count > 1 {
                                resetOTPDigits[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 5 {
                                focusedField = index + 1
                            }
                        }
                }
            }
            .padding(.top, 10)
            
            VStack(spacing: 20) {
                Button(action: verifyResetOTP) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Verify Code")
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                        }
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(AppTheme.authGradient)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 10, y: 5)
                }
                .disabled(isLoading || resetOTPDigits.contains { $0.isEmpty })
                
                Button(action: {
                    if let url = URL(string: "googlegmail://") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        } else {
                            UIApplication.shared.open(URL(string: "https://mail.google.com")!)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.open.fill")
                        Text("Open Gmail")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppTheme.primaryPurple.opacity(0.2), lineWidth: 1.5)
                    )
                }
            }
            
            HStack {
                Text("Didn't receive it?")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                Button(action: sendResetOTP) {
                    Text(resendCooldown > 0 ? "Resend in \(resendCooldown)s" : "Resend OTP")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(resendCooldown > 0 ? .gray : AppTheme.primaryPurple)
                }
                .disabled(resendCooldown > 0)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .onAppear {
            focusedField = 0
        }
    }
    
    private var resetPasswordNewPasswordView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("New Password")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.primaryPurple)
                    
                    Text("Create a strong new password for your account.")
                        .font(AppTheme.bodyFont(size: 18))
                        .foregroundColor(Color.gray)
                }
                
                VStack(spacing: 24) {
                    NeumorphicPasswordField(title: "New Password", placeholder: "At least 8 characters", text: $newPassword, isVisible: $isNewPasswordVisible)
                        .onChange(of: newPassword) { newValue in updateNewPasswordChecks(newValue) }
                    
                    if !newPassword.isEmpty && !isNewPasswordValid {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                RequirementTag(text: "8 Chars", isValid: newPasswordChecks["exactLength"] ?? false)
                                RequirementTag(text: "A-Z", isValid: newPasswordChecks["hasUppercase"] ?? false)
                                RequirementTag(text: "a-z", isValid: newPasswordChecks["hasLowercase"] ?? false)
                                RequirementTag(text: "0-9", isValid: newPasswordChecks["hasNumber"] ?? false)
                                RequirementTag(text: "Special", isValid: newPasswordChecks["hasSpecial"] ?? false)
                            }
                        }
                        .padding(.horizontal, 5)
                    }

                    NeumorphicPasswordField(title: "Confirm Password", placeholder: "••••••••", text: $confirmNewPassword, isVisible: $isNewPasswordVisible, showToggle: false)
                }
                
                VStack(spacing: 20) {
                    Button(action: performResetPassword) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Reset Password")
                                Spacer()
                                Image(systemName: "lock.rotation")
                            }
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor((!newPassword.isEmpty && newPassword == confirmNewPassword) ? .white : .gray)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background((isNewPasswordValid && newPassword == confirmNewPassword) ? AppTheme.authGradient : LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(25)
                        .shadow(color: (isNewPasswordValid && newPassword == confirmNewPassword) ? AppTheme.primaryPurple.opacity(0.3) : .clear, radius: 15, x: 0, y: 10)
                    }
                    .disabled(!isNewPasswordValid || newPassword != confirmNewPassword || isLoading)
                }
                
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
        }
    }
    


    private func performLogin() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        let parameters = ["email": email, "password": password]
        guard let url = URL(string: "\(AppTheme.baseURL)/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing request"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost {
                        self.errorMessage = "Could not connect to server. Please check that the backend is running."
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let user = json["user"] as? [String: Any],
                               let uid = user["id"] as? Int {
                                self.storedUserId = uid
                                self.storedFullName = user["name"] as? String ?? ""
                                self.storedEmail = user["email"] as? String ?? ""
                                
                                // Restore profile data
                                self.storedAge = user["age"] as? String ?? ""
                                self.storedGender = user["gender"] as? String ?? ""
                                self.storedHeight = user["height"] as? String ?? ""
                                self.storedWeight = user["weight"] as? String ?? ""
                                self.storedGoal = user["goal"] as? String ?? ""
                                self.storedActivityLevel = user["activityLevel"] as? String ?? ""
                                self.storedExperience = user["experience"] as? String ?? ""
                                self.storedFocusArea = user["focusArea"] as? String ?? ""
                                self.storedFrequency = user["frequency"] as? String ?? ""
                            }
                        } catch {}
                    }
                    withAnimation {
                        self.isAuthenticated = true
                        self.hasAccount = true
                    }
                } else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else if httpResponse.statusCode == 403 {
                        self.errorMessage = "Please verify your email before signing in."
                    } else if httpResponse.statusCode == 401 {
                        self.errorMessage = "Invalid email or password."
                    } else {
                        self.errorMessage = "Login failed (Status: \(httpResponse.statusCode))"
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    private func sendOTP() {
        if fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            self.errorMessage = "Missing credentials, fill all those"
            self.showAlert = true
            return
        }
        
        guard isEmailValid(email) else {
            self.errorMessage = "Please enter a valid email address."
            self.showAlert = true
            return
        }
        
        if !isPasswordValid {
            self.errorMessage = "Password does not meet requirements."
            self.showAlert = true
            return
        }
        
        if password.trimmingCharacters(in: .whitespaces) != confirmPassword.trimmingCharacters(in: .whitespaces) {
            self.errorMessage = "Passwords do not match."
            self.showAlert = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let parameters = ["email": email]
        guard let url = URL(string: "\(AppTheme.baseURL)/send_signup_otp") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing request"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorCannotConnectToHost {
                        self.errorMessage = "Could not connect to server. Please check that the backend is running."
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.resendCooldown = 60
                    self.navigationDirection = .trailing
                    withAnimation { self.currentStep = .verifyOTP }
                } else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Failed to send verification code."
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    private func verifyOTP() {
        let otp = otpDigits.joined()
        guard otp.count == 6 else { return }
        
        isLoading = true
        errorMessage = ""
        
        // Step 1: Verify OTP
        let parameters = ["email": email, "otp": otp]
        guard let url = URL(string: "\(AppTheme.baseURL)/verify_signup_otp") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing request"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.isLoading = false
                    self.errorMessage = "Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    // Step 2: Register user after successful OTP verification
                    self.performRegistration()
                } else {
                    self.isLoading = false
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Invalid verification code."
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    private func performRegistration() {
        if fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            self.errorMessage = "Please fill in all fields."
            self.showAlert = true
            return
        }
        
        guard isEmailValid(email) else {
            self.errorMessage = "Please enter a valid email address."
            self.showAlert = true
            return
        }
        
        if !isPasswordValid {
            self.errorMessage = "Password does not meet requirements."
            self.showAlert = true
            return
        }
        
        if password != confirmPassword {
            self.errorMessage = "Passwords do not match."
            self.showAlert = true
            return
        }

        isLoading = true
        errorMessage = ""
        
        let parameters = [
            "name": fullName,
            "email": email,
            "phone_number": phoneNumber,
            "password": password
        ]
        
        guard let url = URL(string: "\(AppTheme.baseURL)/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing registration"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Registration Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let uid = (json["user_id"] as? Int) ?? (json["user"] as? [String: Any])?["id"] as? Int {
                                self.storedUserId = uid
                                self.storedFullName = self.fullName
                                self.storedEmail = self.email
                            }
                        } catch {}
                    }
                    
                    self.hasAccount = true
                    self.successMessage = "Account created successfully! Let's personalize your plan."
                    self.navigationDirection = .trailing
                    withAnimation { self.currentStep = .onboardingSurvey }
                } else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Registration failed."
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }

    private func sendResetOTP() {
        guard !forgotPasswordEmail.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        let parameters = ["email": forgotPasswordEmail]
        guard let url = URL(string: "\(AppTheme.baseURL)/forgot_password") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing request"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.resendCooldown = 60
                    self.navigationDirection = .trailing
                    withAnimation { self.currentStep = .resetPasswordVerifyOTP }
                } else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Failed to send reset code (Status: \(httpResponse.statusCode))"
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    private func verifyResetOTP() {
        let otp = resetOTPDigits.joined()
        guard otp.count == 6 else { return }
        
        isLoading = true
        errorMessage = ""
        
        let parameters = ["email": forgotPasswordEmail, "otp": otp]
        guard let url = URL(string: "\(AppTheme.baseURL)/verify_reset_otp") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing request"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.navigationDirection = .trailing
                    withAnimation { self.currentStep = .resetPasswordNewPassword }
                } else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Invalid verification code"
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    private func performResetPassword() {
        let otp = resetOTPDigits.joined()
        guard !newPassword.isEmpty && newPassword.trimmingCharacters(in: .whitespaces) == confirmNewPassword.trimmingCharacters(in: .whitespaces) else { return }
        
        isLoading = true
        errorMessage = ""
        
        let parameters = [
            "email": forgotPasswordEmail,
            "otp": otp,
            "new_password": newPassword
        ]
        
        guard let url = URL(string: "\(AppTheme.baseURL)/reset_password") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            self.errorMessage = "Error preparing request"
            self.showAlert = true
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Server Error"
                    self.showAlert = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.successMessage = "Password reset successfully! Please sign in with your new password."
                    self.showAlert = true
                    self.navigationDirection = .leading
                    withAnimation { self.currentStep = .signIn }
                } else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let msg = json["message"] as? String {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = "Failed to reset password"
                    }
                    self.showAlert = true
                }
            }
        }.resume()
    }
}


// MARK: - Components

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let iconBg: Color
    var picture: String? = nil
    var isCustomImage: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(iconBg)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            .frame(width: 58, height: 58)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                
                Text(subtitle)
                    .font(AppTheme.bodyFont(size: 14))
                    .foregroundColor(.gray.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            
            if let picture = picture {
                if isCustomImage {
                    Image(picture)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: picture)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(iconColor)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.02), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.gray.opacity(0.05), lineWidth: 1)
        )
    }
}



struct NeumorphicTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.black.opacity(0.4))
            
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.6))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.neumorphicBackground)
                    .shadow(color: AppTheme.neumorphicShadowDark, radius: 4, x: 4, y: 4)
                    .shadow(color: AppTheme.neumorphicShadowLight, radius: 4, x: -4, y: -4)
            )
        }
    }
}

struct NeumorphicPasswordField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var showToggle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.black.opacity(0.4))
            
            HStack(spacing: 15) {
                Image(systemName: "lock")
                    .foregroundColor(AppTheme.primaryPurple.opacity(0.6))
                    .frame(width: 20)
                
                if isVisible {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                if showToggle {
                    Button(action: { isVisible.toggle() }) {
                        Image(systemName: isVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.neumorphicBackground)
                    .shadow(color: AppTheme.neumorphicShadowDark, radius: 4, x: 4, y: 4)
                    .shadow(color: AppTheme.neumorphicShadowLight, radius: 4, x: -4, y: -4)
            )
        }
    }
}

struct SurveySelectionItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(red: 100/255, green: 116/255, blue: 139/255))
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? AppTheme.primaryPurple : Color.white)
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

struct CreatingPlanWrapperView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentStep: AuthStep
    @Binding var isAuthenticated: Bool
    @Binding var hasAccount: Bool
    
    var body: some View {
        ZStack {
            AppTheme.neumorphicBackground.ignoresSafeArea()
            CreatingPlanView {
                withAnimation {
                    hasAccount = true
                    isAuthenticated = true
                }
                // Dismiss the authentication view stack
                dismiss()
            }
        }
    }
}

struct CreatingPlanView: View {
    var onComplete: () -> Void
    
    @State private var progress: CGFloat = 0.0
    @State private var activeStepIndex: Int = 0
    @State private var showIconGlow: Bool = false
    
    // User Data for Personalization
    @AppStorage("userId") private var userId: Int = 0
    @AppStorage("userGoal") private var goal: String = "Fitness"
    @AppStorage("userWeight") private var weight: String = "70"
    @AppStorage("userExperience") private var experience: String = "Intermediate"
    @AppStorage("userFocusArea") private var focusArea: String = "Full Body"
    @AppStorage("userAge") private var age: String = ""
    @AppStorage("userGender") private var gender: String = ""
    @AppStorage("userHeight") private var height: String = ""
    @AppStorage("userActivityLevel") private var activityLevel: String = ""
    @AppStorage("userFrequency") private var frequency: String = ""
    
    var steps: [String] {
        [
            "ANALYZING \(weight)KG BODY TYPE FOR \(goal.uppercased())...",
            "CUSTOMIZING \(experience.uppercased()) ROUTINES...",
            "OPTIMIZING FOR \(focusArea.uppercased()) RESULTS...",
            "AI COACH IS FINALIZING YOUR TIMELINE...",
            "YOUR PERSONALIZED JOURNEY STARTS NOW!"
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Spacer to push content down
            Spacer().frame(height: 60)
            
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.primaryPurple.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(showIconGlow ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showIconGlow)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 110, height: 110)
                    .shadow(color: AppTheme.primaryPurple.opacity(0.15), radius: 20, y: 10)
                
                LinearGradient(colors: [Color(red: 130/255, green: 90/255, blue: 255/255), Color(red: 65/255, green: 182/255, blue: 255/255)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 40)
            .onAppear {
                showIconGlow = true
            }
            
            // Texts
            Text("Creating Your Plan")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(AppTheme.primaryPurple)
                .padding(.bottom, 15)
            
            Text(activeStepIndex < steps.count ? steps[activeStepIndex].capitalized : steps.last!.capitalized)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 100/255, green: 116/255, blue: 139/255))
                .padding(.bottom, 50)
            
            // Progress Bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 200, height: 6)
                
                Capsule()
                    .fill(AppTheme.authGradient)
                    .frame(width: 200 * progress, height: 6)
            }
            .padding(.bottom, 60)
            
            // Checklist
            VStack(alignment: .leading, spacing: 25) {
                ForEach(0..<steps.count, id: \.self) { index in
                    HStack(spacing: 15) {
                        if index < activeStepIndex {
                            // Completed
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 34/255, green: 197/255, blue: 94/255)) // Green
                        } else if index == activeStepIndex {
                            // Active / Loading
                            Circle()
                                .stroke(
                                    AngularGradient(gradient: Gradient(colors: [AppTheme.primaryPurple, Color.clear]), center: .center),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                )
                                .frame(width: 20, height: 20)
                                .rotationEffect(.degrees(showIconGlow ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: showIconGlow)
                        } else {
                            // Pending
                            Image(systemName: "circle")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.1))
                        }
                        
                        Text(steps[index])
                            .font(.system(size: 12, weight: .black))
                            .kerning(0.5)
                            .foregroundColor(index <= activeStepIndex ? Color(red: 100/255, green: 116/255, blue: 139/255) : Color.gray.opacity(0.3))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            startPlanCreation()
            syncProfileToServer()
        }
    }
    
    private func syncProfileToServer() {
        print("Starting syncProfileToServer...")
        let profile: [String: String] = [
            "age": age,
            "gender": gender,
            "height": height,
            "weight": weight,
            "goal": goal,
            "activityLevel": activityLevel,
            "experience": experience,
            "focusArea": focusArea,
            "frequency": frequency
        ]
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "profile": profile
        ]
        
        guard let url = URL(string: "\(AppTheme.baseURL)/update_profile") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch { return }
        
        print("Sending update_profile for uid: \(userId)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("update_profile ERROR: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("update_profile status code: \(httpResponse.statusCode)")
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("update_profile response: \(str)")
                }
            }
        }
        task.resume()
    }
    
    private func startPlanCreation() {
        let totalDuration: TimeInterval = 4.0
        let stepDuration = totalDuration / Double(steps.count)
        
        withAnimation(.linear(duration: totalDuration)) {
            progress = 1.0
        }
        
        for i in 0...steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * stepDuration)) {
                withAnimation {
                    activeStepIndex = i
                }
                
                if i == steps.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }
}

// MARK: - Helper Components
struct SocialIconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                .frame(width: 64, height: 64)
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

struct RequirementTag: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 8))
            Text(text)
                .font(.system(size: 9, weight: .bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(isValid ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        )
        .foregroundColor(isValid ? .green : .gray)
    }
}
