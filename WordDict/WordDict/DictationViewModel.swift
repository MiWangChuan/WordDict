import SwiftUI
import Combine

class DictationViewModel: ObservableObject {
    @Published var words: [Word] = []
    @Published var currentIndex: Int = 0
    @Published var isRevealed: Bool = false
    @Published var isRandom: Bool = false
    
    // Maintain a shuffled list of indices if in random mode
    private var randomIndices: [Int] = []
    
    var currentWord: Word? {
        if words.isEmpty { return nil }
        if isRandom {
             if currentIndex < randomIndices.count {
                 return words[randomIndices[currentIndex]]
             }
             return nil
        } else {
             if currentIndex < words.count {
                 return words[currentIndex]
             }
             return nil
        }
    }
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        // In a real app, this would load from a file picker. 
        // For now, we load the static sample we created.
        if let path = Bundle.main.path(forResource: "sample_words", ofType: "md") {
           do {
               let content = try String(contentsOfFile: path, encoding: .utf8)
               self.words = WordParser.parseContent(content)
               resetPlayback()
           } catch {
               print("Error loading sample data: \(error)")
           }
        } else {
             // Fallback if bundle not ready (e.g. preview)
             let sample = """
             boy[bɔ i]n. 男孩
             girl[ɡɜːl]n. 女孩
             """
             self.words = WordParser.parseContent(sample)
             resetPlayback()
        }
    }
    
    // Used for importing external files
    func loadWords(from content: String) {
        self.words = WordParser.parseContent(content)
        resetPlayback()
        speakCurrent()
    }
    
    private func resetPlayback() {
        if isRandom {
            randomIndices = Array(0..<words.count).shuffled()
        }
        currentIndex = 0
        isRevealed = false
    }
    
    func toggleRandomMode() {
        isRandom.toggle()
        resetPlayback()
        speakCurrent()
    }
    
    func next() {
        if words.isEmpty { return }
        
        // Loop logic: if at end, go to 0, else increment
        if currentIndex < words.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0 // Wrap around
            // User Request: Reshuffle when looping back to start in random mode
            if isRandom {
                randomIndices = Array(0..<words.count).shuffled()
            }
        }
        
        isRevealed = false
        speakCurrent()
    }
    
    func previous() {
        if words.isEmpty { return }
        
        // Loop logic: if at 0, go to end, else decrement
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = words.count - 1 // Wrap around
        }
        
        isRevealed = false
        speakCurrent()
    }
    
    func speakCurrent() {
        guard let word = currentWord else { return }
        TTSManager.shared.speak(word.text)
    }
    
    func toggleReveal() {
        withAnimation {
            isRevealed.toggle()
        }
        speakCurrent()
    }
}
