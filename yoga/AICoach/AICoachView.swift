import SwiftUI

struct AICoachView: View {
    @Binding var selectedTab: Int
    @FocusState private var isInputFocused: Bool
    @StateObject private var viewModel = AICoachViewModel()
    @State private var messageText = ""

    var body: some View {
        ZStack {
            Color(red: 250/255, green: 250/255, blue: 252/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 1. HEADER ─────────────────────────────────────────
                headerView

                // ── 2. CHAT MESSAGES ──────────────────────────────────
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                chatBubble(for: message)
                                    .id(message.id)
                            }
                            if viewModel.isLoading {
                                typingIndicator
                                    .padding(.leading, 24)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id("__bottom__")
                        }
                        .padding(.vertical, 16)
                    }
                    .onAppear {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(
                            for: UIResponder.keyboardWillShowNotification)
                    ) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ── 3. INPUT BAR ──────────────────────────────────────
                VStack(spacing: 0) {
                    Divider().opacity(0.15)
                    suggestionPills
                    inputRow
                        .padding(.vertical, 12)
                }
                .background(Color(red: 250/255, green: 250/255, blue: 252/255))
            }
        }
        .onChange(of: isInputFocused) { focused in
            if focused {
                // Small delay to let keyboard animation start
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil)
                }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("__bottom__", anchor: .bottom)
        }
    }

    private var headerView: some View {
        HStack(spacing: 15) {
            // BACK BUTTON
            Button(action: {
                withAnimation {
                    selectedTab = 0
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.primaryPurple)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(AppTheme.primaryPurple.opacity(0.1))
                    )
            }

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 130/255, green: 90/255, blue: 255/255),
                                Color(red: 65/255, green: 182/255, blue: 255/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Coach")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(AppTheme.primaryPurple)
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.isLoading ? Color.blue : Color.green)
                        .frame(width: 6, height: 6)
                    Text(viewModel.isLoading ? "THINKING..." : "READY")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.gray.opacity(0.6))
                        .kerning(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 12)
        .background(Color.white)
        .overlay(Divider().opacity(0.1), alignment: .bottom)
    }

    private var suggestionPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SuggestionPill(icon: "brain.fill", text: "POSE\nHELP")
                    .onTapGesture { messageText = "I need help with a yoga pose" }
                SuggestionPill(icon: "apple.logo", text: "DIET\nPLAN")
                    .onTapGesture { messageText = "Create a vegetarian diet plan" }
                SuggestionPill(icon: "heart.fill", text: "BACK\nPAIN")
                    .onTapGesture { messageText = "Yoga for back pain" }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var inputRow: some View {
        HStack(spacing: 12) {
            TextField("Ask your coach anything...", text: $messageText)
                .focused($isInputFocused)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 18)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
                .onSubmit { handleSend() }

            Button(action: handleSend) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.primaryPurple)
                        .frame(width: 50, height: 50)
                        .shadow(color: AppTheme.primaryPurple.opacity(0.35), radius: 8, y: 4)
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(
                messageText.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                || viewModel.isLoading
            )
        }
        .padding(.horizontal, 20)
    }

    private func handleSend() {
        let text = messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        viewModel.sendMessage(text)
        messageText = ""
    }

    @ViewBuilder
    private func chatBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if !message.isUser {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 35, height: 35)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
                        .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5))
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.primaryPurple)
                }
            } else {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(
                        message.isUser
                            ? .white
                            : Color(red: 26/255, green: 32/255, blue: 44/255)
                    )
                    .lineSpacing(4)
                    .padding(18)
                    .background(message.isUser ? AppTheme.primaryPurple : Color.white)
                    .cornerRadius(22)
                    .cornerRadius(4, corners: message.isUser ? [.topRight] : [.topLeft])
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 4)

                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
                    .padding(.horizontal, 8)
            }

            if !message.isUser { Spacer() }
        }
        .padding(.horizontal, 20)
    }

    private var typingIndicator: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(AppTheme.primaryPurple.opacity(0.5))
                    .frame(width: 7, height: 7)
                    .offset(y: viewModel.isLoading ? -5 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.18),
                        value: viewModel.isLoading
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .padding(.leading, 20)
    }

    private func formatTimestamp(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}
