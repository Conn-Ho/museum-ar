import SwiftUI
import SceneKit
import AVFoundation

struct ExhibitDetailView: View {
    let exhibit: Exhibit
    @State private var isCollected = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            // 3D 模型预览
            SceneView(scene: exhibit.detailScene, options: [.allowsCameraControl])
                .frame(height: 300)
            
            // 文字介绍
            ScrollView {
                Text(exhibit.description)
                    .padding()
            }
            
            // 音频控制
            HStack {
                if let _ = exhibit.audioURL {
                    Button(action: toggleAudio) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                
                Button(action: { isCollected.toggle() }) {
                    Image(systemName: isCollected ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundColor(isCollected ? .red : .gray)
                }
            }
            .padding()
        }
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            audioPlayer?.stop()
        }
    }
    
    private func setupAudioPlayer() {
        guard let audioURL = exhibit.audioURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func toggleAudio() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }
}