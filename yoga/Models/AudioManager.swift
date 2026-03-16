import SwiftUI
import Combine
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var bgMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    
    @Published var soundEffectsEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEffectsEnabled, forKey: "soundEffects") }
    }
    
    @Published var bgMusicEnabled: Bool {
        didSet { 
            UserDefaults.standard.set(bgMusicEnabled, forKey: "backgroundMusic")
            toggleBackgroundMusic(isOn: bgMusicEnabled)
        }
    }
    
    @Published var timerChimeEnabled: Bool {
        didSet { UserDefaults.standard.set(timerChimeEnabled, forKey: "timerChime") }
    }
    
    private init() {
        // Load initial values
        self.soundEffectsEnabled = UserDefaults.standard.object(forKey: "soundEffects") as? Bool ?? true
        self.bgMusicEnabled = UserDefaults.standard.bool(forKey: "backgroundMusic")
        self.timerChimeEnabled = UserDefaults.standard.object(forKey: "timerChime") as? Bool ?? true
        
        setupAudioSession()
        if bgMusicEnabled {
            playBackgroundMusic()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playSoundEffect(name: String) {
        guard soundEffectsEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ?? 
                Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.play()
        } catch {
            print("Could not play sound effect: \(error)")
        }
    }
    
    func playTimerChime() {
        guard timerChimeEnabled else { return }
        playSoundEffect(name: "chime")
    }
    
    func playClick() {
        playSoundEffect(name: "click")
    }
    
    func startBackgroundMusic() {
        playBackgroundMusic()
    }
    
    func stopBackgroundMusic() {
        bgMusicPlayer?.stop()
    }
    
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "meditation_bg", withExtension: "mp3") else { 
            print("Meditation music file not found")
            return 
        }
        
        do {
            bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
            bgMusicPlayer?.numberOfLoops = -1 // Loop forever
            bgMusicPlayer?.volume = 0.3
            bgMusicPlayer?.play()
        } catch {
            print("Could not play background music: \(error)")
        }
    }
    
    func toggleBackgroundMusic(isOn: Bool) {
        if isOn {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }
}
