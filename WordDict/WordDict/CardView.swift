import SwiftUI

struct CardView: View {
    let word: Word?
    let isRevealed: Bool
    let onPlayAudio: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
            
            VStack(spacing: 20) {
                if let word = word {
                    // Always show "Listening..." or some indicator when hidden?
                    // "Default only sound"
                    
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    if isRevealed {
                        Text(word.text)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if let phonetic = word.phonetic {
                            Text("[\(phonetic)]")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        Text(word.meaning)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.primary)
                    } else {
                        Text("Listen and Write")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Swipe Down to Reveal")
                            .font(.footnote)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.top, 50)
                    }
                } else {
                    Text("No words loaded")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .padding(30)
        .onTapGesture {
            onPlayAudio()
        }
    }
}
