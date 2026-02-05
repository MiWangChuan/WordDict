import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject var viewModel = DictationViewModel()
    @State private var showFileImporter = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // Header Status
                    VStack(spacing: 8) {
                        // Filename + Mode
                        HStack {
                            Text(viewModel.currentFilename)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.toggleRandomMode()
                            }) {
                                Image(systemName: viewModel.isRandom ? "shuffle.circle.fill" : "arrow.forward.circle")
                                    .font(.title2)
                            }
                        }
                        
                        // Counters
                        HStack {
                            HStack(spacing: 4) {
                                Text("Remaining:")
                                    .foregroundColor(.gray)
                                Text("\(viewModel.remainingCount)")
                                    .foregroundColor(.primary) // Darker/Default text color
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("Completed:")
                                    .foregroundColor(.gray)
                                Text("\(viewModel.completedCount)")
                                    .foregroundColor(.primary) // Darker/Default text color
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.footnote)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Card Area with Gestures
                    if viewModel.words.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("All words completed!")
                                .font(.title2)
                            Button("Restart") {
                                // Just reloading the current file effectively restarts
                                // Or we could add a restart function. 
                                // Toggling mode does it, but let's add a restart or just "Reload" logic.
                                // For now, simple toggle mode resets.
                                viewModel.toggleRandomMode() 
                                viewModel.toggleRandomMode()
                            }
                        }
                    } else {
                        CardView(
                            word: viewModel.currentWord,
                            isRevealed: viewModel.isRevealed,
                            onPlayAudio: {
                                viewModel.speakCurrent()
                            }
                        )
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let horizontalAmount = value.translation.width
                                    let verticalAmount = value.translation.height
                                    
                                    if abs(horizontalAmount) > abs(verticalAmount) {
                                        // Horizontal Swipe
                                        if horizontalAmount < -50 {
                                            // Swipe Left -> Next
                                            withAnimation {
                                                viewModel.next()
                                            }
                                        } else if horizontalAmount > 50 {
                                            // Swipe Right -> Previous
                                            withAnimation {
                                                viewModel.previous()
                                            }
                                        }
                                    } else {
                                        // Vertical Swipe
                                        if verticalAmount < -50 {
                                            // Swipe Up -> Toggle
                                            viewModel.toggleReveal()
                                        } else if verticalAmount > 50 {
                                            // Swipe Down -> Toggle
                                            viewModel.toggleReveal()
                                        }
                                    }
                                }
                        )
                    }
                    
                    Spacer()
                    
                    // Instructions
                    HStack(spacing: 30) {
                        Image(systemName: "arrow.left").caption("Next")
                        Image(systemName: "arrow.right").caption("Prev")
                        Image(systemName: "arrow.up").caption("Toggle")
                        Image(systemName: "arrow.down").caption("Toggle")
                    }
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.bottom)
                }
            }
            .navigationTitle("WordDict")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 242/255, green: 242/255, blue: 247/255))
                            .frame(width: 36, height: 36)
                        Image(systemName: "doc.badge.plus")
                            .foregroundColor(.primary)
                    }
                    .onTapGesture {
                        showFileImporter = true
                    }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [UTType.plainText], // Markdown is treated as plain text mostly or we can be specific
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    if selectedFile.startAccessingSecurityScopedResource() {
                        let content = try String(contentsOf: selectedFile, encoding: .utf8)
                        let filename = selectedFile.lastPathComponent
                        DispatchQueue.main.async {
                            viewModel.loadWords(from: content, filename: filename)
                        }
                        selectedFile.stopAccessingSecurityScopedResource()
                    }
                } catch {
                    print("Error reading file: \(error)")
                }
            }
            .onAppear {
                // Initial load
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.speakCurrent()
                }
            }
        }
    }
}

extension Image {
    func caption(_ text: String) -> some View {
        VStack {
            self
            Text(text)
        }
    }
}
