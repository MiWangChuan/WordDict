import SwiftUI
import Combine

class DictationViewModel: ObservableObject {
    @Published var words: [Word] = [] // The current active playlist
    @Published var currentIndex: Int = 0
    @Published var isRevealed: Bool = false
    @Published var isRandom: Bool = false
    @Published var currentFilename: String = "Sample"
    
    // Store all words to support reset logic
    private var allWords: [Word] = []
    
    var currentWord: Word? {
        if words.isEmpty { return nil }
        if currentIndex < words.count {
            return words[currentIndex]
        }
        return nil
    }
    
    var completedCount: Int {
        return allWords.count - words.count
    }
    
    var remainingCount: Int {
        return words.count
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
               self.allWords = WordParser.parseContent(content)
               self.currentFilename = "sample_words"
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
             self.allWords = WordParser.parseContent(sample)
             self.currentFilename = "Sample"
             resetPlayback()
        }
    }
    
    // Used for importing external files
    func loadWords(from content: String, filename: String) {
        self.allWords = WordParser.parseContent(content)
        self.currentFilename = (filename as NSString).deletingPathExtension
        resetPlayback()
        speakCurrent()
    }
    
    private func resetPlayback() {
        // Reset Logic: 
        // 1. Reload words from allWords
        // 2. If random, shuffle them
        // 3. Reset index and revealed state
        
        if isRandom {
            self.words = allWords.shuffled()
        } else {
            self.words = allWords
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
        
        // Smart Completion Logic:
        // If the user did NOT flip the card (isRevealed == false),
        // we consider it mastered and remove it from the list.
        if !isRevealed {
            markCurrentAsMastered()
        } else {
            // Normal navigation: move to next
            if currentIndex < words.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0 // Wrap around
            }
        }
        
        isRevealed = false
        speakCurrent()
    }
    
    private func markCurrentAsMastered() {
        guard currentIndex < words.count else { return }
        words.remove(at: currentIndex)
        
        // After removal:
        // If list empty -> Done.
        // If not empty -> currentIndex now points to the next word automatically (since arrays shift).
        // If we were at the last item, currentIndex is now out of bounds words.count.
        // So we need to wrap or clamp.
        
        if words.isEmpty {
            currentIndex = 0
            return
        }
        
        if currentIndex >= words.count {
            currentIndex = 0
        }
        
        // Do NOT increment currentIndex here because the next word 'slid' into the current slot.
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
