import SwiftUI
import AVFoundation
import PencilKit

struct ARMessageDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var messageManager: ARMessageManager
    
    let message: ARMessage
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var drawing: PKDrawing?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 留言信息
                    HStack {
                        Image(systemName: messageTypeIcon)
                            .font(.title)
                            .foregroundColor(messageTypeColor)
                        
                        VStack(alignment: .leading) {
                            Text(message.authorName)
                                .font(.headline)
                            
                            Text(message.createdAt, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // 留言内容
                    if message.type == .text {
                        Text(message.content)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    } else if message.type == .audio {
                        VStack {
                            Button(action: toggleAudio) {
                                HStack {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.largeTitle)
                                    Text(isPlaying ? "暂停" : "播放语音留言")
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if message.type == .drawing {
                        if let drawingData = message.drawingData,
                           let drawing = try? PKDrawing(data: drawingData) {
                            DrawingDisplayView(drawing: drawing)
                                .frame(height: 300)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .padding()
                        } else {
                            Text("无法加载涂鸦")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("留言详情")
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    messageManager.deleteMessage(id: message.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            )
            .onAppear {
                if message.type == .audio {
                    prepareAudio()
                } else if message.type == .drawing {
                    loadDrawing()
                }
            }
            .onDisappear {
                if isPlaying {
                    audioPlayer?.stop()
                    isPlaying = false
                }
            }
        }
    }
    
    private var messageTypeIcon: String {
        switch message.type {
        case .text:
            return "text.bubble.fill"
        case .audio:
            return "waveform.circle.fill"
        case .drawing:
            return "pencil.tip.crop.circle.fill"
        }
    }
    
    private var messageTypeColor: Color {
        switch message.type {
        case .text:
            return .blue
        case .audio:
            return .green
        case .drawing:
            return .orange
        }
    }
    
    private func prepareAudio() {
        guard let audioURL = message.audioURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("无法加载音频: \(error)")
        }
    }
    
    private func toggleAudio() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    private func loadDrawing() {
        guard let drawingData = message.drawingData else { return }
        
        do {
            drawing = try PKDrawing(data: drawingData)
        } catch {
            print("无法加载涂鸦: \(error)")
        }
    }
}

struct DrawingDisplayView: UIViewRepresentable {
    let drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.isUserInteractionEnabled = false
        canvasView.backgroundColor = .white
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
} 