import Foundation
import SwiftUI
import Combine
class AICoachViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private let apiKey = "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"
    private let openRouterURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
    
    init() {
        // Initial welcome message
        messages.append(ChatMessage(id: UUID(), text: "Hi! I am your ZenForge AI Coach. How can I assist with your transformation today? We can discuss poses, diet, or track your goals.", isUser: false, timestamp: Date()))
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(id: UUID(), text: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        isLoading = true
        
        var request = URLRequest(url: openRouterURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ZenForge Yoga App", forHTTPHeaderField: "HTTP-Referer") // OpenRouter requirement
        request.addValue("ZenForge", forHTTPHeaderField: "X-Title")
        
        let apiMessages = messages.map { ["role": $0.isUser ? "user" : "assistant", "content": $0.text] }
        
        let body: [String: Any] = [
            "model": "google/gemini-2.0-flash-lite-001", // Fast and efficient for chat
            "messages": apiMessages
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error encoding request: \(error)")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("API Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        let aiMessage = ChatMessage(id: UUID(), text: content.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false, timestamp: Date())
                        self?.messages.append(aiMessage)
                    }
                } catch {
                    print("JSON Decode Error: \(error)")
                }
            }
        }.resume()
    }
}
