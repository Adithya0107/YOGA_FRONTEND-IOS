import SwiftUI
import WebKit
import Network
import Combine

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = true

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

struct UniversalVideoPlayer: View {
    let videoURL: String
    @Binding var isPlaying: Bool
    var onStateChange: ((Int) -> Void)?
    
    // Custom styling for "Perfect" integration
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 5
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        ZStack {
            if !networkMonitor.isConnected {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Internet connection required to play this video.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.05))
            } else {
                VideoWebView(url: videoURL, isPlaying: $isPlaying, onStateChange: onStateChange)
            }
        }
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(shadowRadius > 0 ? 0.1 : 0), radius: shadowRadius)
    }
}

struct YouTubePlayerView: View {
    let videoURL: String
    @Binding var isPlaying: Bool
    var onStateChange: ((Int) -> Void)?
    
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 5
    
    init(videoURL: String, isPlaying: Binding<Bool> = .constant(false), cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 5, onStateChange: ((Int) -> Void)? = nil) {
        self.videoURL = videoURL
        self._isPlaying = isPlaying
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.onStateChange = onStateChange
    }
    
    var body: some View {
        UniversalVideoPlayer(videoURL: videoURL, isPlaying: $isPlaying, onStateChange: onStateChange, cornerRadius: cornerRadius, shadowRadius: shadowRadius)
    }
}

struct VideoWebView: UIViewRepresentable {
    let url: String
    @Binding var isPlaying: Bool
    var onStateChange: ((Int) -> Void)?
    
    private var isGoogleDrive: Bool {
        url.contains("drive.google.com")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let contentController = WKUserContentController()
        if !isGoogleDrive {
            contentController.add(context.coordinator, name: "youtubeHandler")
        }
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if !context.coordinator.isLoaded {
            if isGoogleDrive {
                loadGoogleDrive(uiView)
            } else {
                loadYouTube(uiView, context: context)
            }
            context.coordinator.isLoaded = true
        } else {
            if !isGoogleDrive {
                let jsCommand = isPlaying ? "if(typeof player !== 'undefined' && player.playVideo) player.playVideo();" : "if(typeof player !== 'undefined' && player.pauseVideo) player.pauseVideo();"
                uiView.evaluateJavaScript(jsCommand)
            }
        }
    }
    
    private func loadGoogleDrive(_ webView: WKWebView) {
        var driveURL = url
        if driveURL.contains("/view") {
            driveURL = driveURL.replacingOccurrences(of: "/view", with: "/preview")
        } else if !driveURL.contains("/preview") && driveURL.contains("/file/d/") {
            // Basic attempt to inject preview if missing
            let parts = driveURL.components(separatedBy: "?")
            if var base = parts.first {
                if !base.hasSuffix("/preview") {
                    base += "/preview"
                }
                driveURL = base + (parts.count > 1 ? "?" + parts[1] : "")
            }
        }
        
        if let requestURL = URL(string: driveURL) {
            webView.load(URLRequest(url: requestURL))
        }
    }
    
    private func loadYouTube(_ webView: WKWebView, context: Context) {
        let videoId = extractVideoId(from: url)
        let htmlSnippet = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body, html { margin: 0; padding: 0; background-color: #000000; width: 100%; height: 100%; overflow: hidden; }
                .video-container { position: relative; width: 100%; height: 100%; }
                #player { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
            </style>
        </head>
        <body>
            <div class="video-container">
                <div id="player"></div>
            </div>
            
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '\(videoId)',
                    playerVars: {
                        'playsinline': 1,
                        'modestbranding': 1,
                        'rel': 0,
                        'controls': 1,
                        'showinfo': 0,
                        'autoplay': 1
                    },
                    events: {
                        'onStateChange': onPlayerStateChange
                    }
                });
            }

            function onPlayerStateChange(event) {
                window.webkit.messageHandlers.youtubeHandler.postMessage({ "type": "state", "value": event.data });
            }
        </script>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlSnippet, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: VideoWebView
        var isLoaded = false
        
        init(_ parent: VideoWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if parent.isGoogleDrive {
                // Inject CSS to hide Google Drive header and improve player appearance
                let css = """
                .ndfHFb-c4Sojc-R6O9id-u08Mce { display: none !important; } /* Hide Title bar */
                .ndfHFb-c4Sojc-m9v9vb { display: none !important; } /* Hide More actions */
                .ytp-chrome-top { display: none !important; } /* Hide YT top info */
                body { background-color: black !important; }
                """
                let js = "var style = document.createElement('style'); style.innerHTML = '\(css.replacingOccurrences(of: "\n", with: ""))'; document.head.appendChild(style);"
                webView.evaluateJavaScript(js)
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let dict = message.body as? [String: Any], let type = dict["type"] as? String {
                DispatchQueue.main.async {
                    if type == "state", let val = dict["value"] as? Int {
                        self.parent.onStateChange?(val)
                    }
                }
            }
        }
    }
    
    private func extractVideoId(from original: String) -> String {
        if original.contains("youtu.be/") {
            let path = original.components(separatedBy: "youtu.be/").last ?? ""
            return path.components(separatedBy: "?").first?.components(separatedBy: "/").first ?? ""
        }
        if original.contains("v=") {
            let parts = original.components(separatedBy: "v=")
            if parts.count > 1 {
                return parts[1].components(separatedBy: "&").first ?? ""
            }
        }
        return original
    }
}

