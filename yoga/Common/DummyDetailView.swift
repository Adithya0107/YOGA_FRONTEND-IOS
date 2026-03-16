import SwiftUI

struct DummyDetailView: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primaryPurple)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                
                Text("This feature is coming soon!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}
