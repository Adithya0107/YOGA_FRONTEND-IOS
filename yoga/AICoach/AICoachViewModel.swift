import Foundation
import SwiftUI
import Combine

class AICoachViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private var systemPrompt: String {
        let name = UserDefaults.standard.string(forKey: "userFullName") ?? "friend"
        return "You are ZenForge AI Coach, \(name)'s expert yoga instructor and wellness advisor."
    }
    
    init() {
        messages.append(ChatMessage(
            id: UUID(),
            text: "Hi! I am your ZenForge AI Coach. How can I assist with your transformation today? We can discuss poses, diet, or pain relief.",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(id: UUID(), text: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        isLoading = true
        
        // Brief delay for realism
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            let responseText: String
            if let localAnswer = LocalKnowledgeBase.findAnswer(for: text) {
                // Use data from our trained knowledge base
                responseText = localAnswer
            } else {
                // Friendly fallback for queries outside the local training data
                responseText = """
                👋 I'm currently focused on helping you with **Yoga Poses**, **Diet Plans**, **Pain Relief**, and **Wellness**.
                
                Could you please ask me something more specific about one of those topics? For example:
                • "Yoga for back pain"
                • "Vegetarian diet plan"
                • "How to build muscle"
                • "Yoga for better sleep"
                
                I'm here to help you stay healthy and balanced! 🧘‍♀️✨
                """
            }
            
            let aiMessage = ChatMessage(
                id: UUID(),
                text: responseText,
                isUser: false,
                timestamp: Date()
            )
            self.messages.append(aiMessage)
        }
    }
    
    private func appendErrorMessage(_ text: String) {
        let errorMsg = ChatMessage(id: UUID(), text: text, isUser: false, timestamp: Date())
        messages.append(errorMsg)
    }
}
