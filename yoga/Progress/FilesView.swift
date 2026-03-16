import SwiftUI

struct FilesView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("saved_videos_json") private var savedVideosJSON: String = "[]"
    @State private var savedVideos: [SavedVideo] = []
    
    @State private var showUploadForm = false
    @State private var newTitle = ""
    @State private var newURL = ""
    @State private var newInstructor = ""
    
    @State private var activeVideo: SavedVideo?
    
    var body: some View {
        ZStack {
            AppTheme.neumorphicBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 0.5))
                    }
                    
                    Text("My Sessions")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 26/255, green: 32/255, blue: 44/255))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: { showUploadForm = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(AppTheme.primaryPurple)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.primaryPurple.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                if savedVideos.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "video.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.primaryPurple.opacity(0.2))
                        
                        Text("No sessions uploaded yet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Button("Upload First Session") {
                            showUploadForm = true
                        }
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(AppTheme.primaryPurple)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(savedVideos) { video in
                                FeaturedClassCard(
                                    title: video.title,
                                    instructor: video.instructor ?? "Self Practice",
                                    time: "Recorded",
                                    level: "Personal",
                                    videoURL: video.videoURL,
                                    imageName: "play.tv"
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteVideo(video)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear(perform: loadVideos)
        .sheet(isPresented: $showUploadForm) {
            UploadSessionView { title, url, instructor in
                saveVideo(title: title, url: url, instructor: instructor)
                showUploadForm = false
            }
        }
    }
    
    private func loadVideos() {
        if let data = savedVideosJSON.data(using: .utf8) {
            savedVideos = (try? JSONDecoder().decode([SavedVideo].self, from: data)) ?? []
        }
    }
    
    private func saveVideo(title: String, url: String, instructor: String) {
        let newVideo = SavedVideo(title: title, videoURL: url, instructor: instructor, dateAdded: Date())
        savedVideos.append(newVideo)
        syncStorage()
    }
    
    private func deleteVideo(_ video: SavedVideo) {
        savedVideos.removeAll { $0.id == video.id }
        syncStorage()
    }
    
    private func syncStorage() {
        if let data = try? JSONEncoder().encode(savedVideos),
           let json = String(data: data, encoding: .utf8) {
            savedVideosJSON = json
        }
    }
}

struct UploadSessionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var url = ""
    @State private var instructor = ""
    
    var onSave: (String, String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Details")) {
                    TextField("Title (e.g. Morning Stretch)", text: $title)
                    TextField("YouTube URL", text: $url)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Instructor (Optional)", text: $instructor)
                }
            }
            .navigationTitle("Upload Session")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if !title.isEmpty && !url.isEmpty {
                        onSave(title, url, instructor)
                    }
                }
                .disabled(title.isEmpty || url.isEmpty)
            )
        }
    }
}
