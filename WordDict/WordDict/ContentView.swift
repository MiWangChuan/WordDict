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
                    HStack {
                         Text("\(viewModel.currentIndex + 1) / \(viewModel.words.count)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            viewModel.toggleRandomMode()
                        }) {
                            Image(systemName: viewModel.isRandom ? "shuffle.circle.fill" : "arrow.forward.circle")
                                .font(.title)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Card Area with Gestures
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
                    Button(action: { showFileImporter = true }) {
                        Image(systemName: "doc.badge.plus")
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
                        DispatchQueue.main.async {
                            viewModel.loadWords(from: content)
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
