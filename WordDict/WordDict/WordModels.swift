import Foundation

struct Word: Identifiable, Codable {
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
}

class WordParser {
    /// Parses a line in the format: word[phonetic]meaning
    /// Example: boy[bɔ i]n. 男孩,少年,家伙
    static func parseLine(_ line: String) -> Word? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedLine.isEmpty { return nil }
        
        // Regex pattern to capture:
        // 1. The word (everything before the first [)
        // 2. The phonetic (content inside [])
        // 3. The meaning (content after ])
        // Note: This regex assumes the format strictly follows word[phonetic]meaning
        // If [] is missing, we might need a fallback.
        
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
            // Fallback: If no brackets found, treat whole line as word, or split by space?
            // For now, strict adherence to the requested format is safer.
            // Or we can try to find simple "word meaning" split by space.
            // Let's implement a simple fallback: Everything before the first space is word, rest is meaning.
             let components = trimmedLine.split(separator: " ", maxSplits: 1)
             if components.count >= 2 {
                 let text = String(components[0])
                 let meaning = String(components[1])
                 return Word(text: text, phonetic: nil, meaning: meaning)
             }
             
             // If really just one word
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
