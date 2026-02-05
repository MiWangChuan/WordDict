
import Foundation

// Copy-pasting the parser code here for script execution since we can't easily import from another file in a standalone script without module setup.
struct Word: Identifiable, CustomStringConvertible {
    let id: UUID
    let text: String
    let phonetic: String?
    let meaning: String
    
    init(id: UUID = UUID(), text: String, phonetic: String?, meaning: String) {
        self.id = id
        self.text = text
        self.phonetic = phonetic
        self.meaning = meaning
    }
    
    var description: String {
        return "Word(text: \"\(text)\", phonetic: \"\(phonetic ?? "nil")\", meaning: \"\(meaning)\")"
    }
}

class WordParser {
    static func parseLine(_ line: String) -> Word? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedLine.isEmpty { return nil }
        
        let pattern = #"^(.+?)\[(.+?)\](.+)$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(location: 0, length: trimmedLine.utf16.count)
        
        if let match = regex.firstMatch(in: trimmedLine, options: [], range: range) {
            let textRange = match.range(at: 1)
            let phoneticRange = match.range(at: 2)
            let meaningRange = match.range(at: 3)
            
            let text = String(trimmedLine[Range(textRange, in: trimmedLine)!]).trimmingCharacters(in: .whitespaces)
            let phonetic = String(trimmedLine[Range(phoneticRange, in: trimmedLine)!])
            let meaning = String(trimmedLine[Range(meaningRange, in: trimmedLine)!]).trimmingCharacters(in: .whitespaces)
            
            return Word(text: text, phonetic: phonetic, meaning: meaning)
        } else {
             let components = trimmedLine.split(separator: " ", maxSplits: 1)
             if components.count >= 2 {
                 let text = String(components[0])
                 let meaning = String(components[1])
                 return Word(text: text, phonetic: nil, meaning: meaning)
             }
             return Word(text: trimmedLine, phonetic: nil, meaning: "")
        }
    }
    
    static func parseContent(_ content: String) -> [Word] {
        var words: [Word] = []
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            if let word = parseLine(line) {
                words.append(word)
            }
        }
        return words
    }
}

// Main Test Execution
let samplePath = "/Users/richardwang/program/WordDict/sample_words.md"
do {
    let content = try String(contentsOfFile: samplePath, encoding: .utf8)
    print("Content loaded. Parsing...")
    let words = WordParser.parseContent(content)
    
    print("Parsed \(words.count) words:")
    for word in words {
        print(word)
    }
    
    // Assertions for verification
    if words.count == 5 {
        print("\n✅ Count check passed.")
    } else {
        print("\n❌ Count check failed. Expected 5, got \(words.count)")
    }
    
    if let boy = words.first, boy.text == "boy" && boy.phonetic == "bɔ i" {
        print("✅ Parsing logic check passed.")
    } else {
        print("❌ Parsing logic check failed.")
    }
    
} catch {
    print("Error reading file: \(error)")
}
