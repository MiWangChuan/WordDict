import AVFoundation

class TTSManager: NSObject {
    static let shared = TTSManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        // Optional: configure audio session to ensure it plays even if mute switch is on (Category Playback)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session aspect: \(error)")
        }
    }
    
    func speak(_ text: String) {
        // Stop any ongoing speech immediately when a new request comes in
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Default to US English
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        synthesizer.speak(utterance)
    }
}
