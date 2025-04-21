import SwiftUI
import SceneKit
import AVFoundation

struct ExhibitDetailView: View {
    let exhibit: Exhibit
    @Binding var isPresented: Bool  // 改名为更通用的名称
    @State private var isCollected = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var showComments = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏
            HStack {
                // 把手示意条
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 40, height: 5)
                
                Spacer()
                
                // 关闭按钮
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // 标题区域
            Text(exhibit.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            if showComments {
                // 留言列表视图
                CommentListView(exhibitId: exhibit.id)
            } else {
                // 展品描述
                ScrollView {
                    Text(exhibit.description)
                        .font(.body)
                        .lineSpacing(5)
                        .padding()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom, 20)
            }
            
            // 底部按钮区域
            HStack(spacing: 40) {
                // 语音讲解按钮
                Button(action: toggleAudio) {
                    VStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                        Text("讲解")
                            .font(.caption)
                    }
                }
                .foregroundColor(.white)
                
                // 收藏按钮
                Button(action: { isCollected.toggle() }) {
                    VStack {
                        Image(systemName: isCollected ? "heart.fill" : "heart")
                            .font(.title2)
                        Text("收藏")
                            .font(.caption)
                    }
                }
                .foregroundColor(.white)
                
                // 留言按钮
                Button(action: { showComments.toggle() }) {
                    VStack {
                        Image(systemName: showComments ? "bubble.left.fill" : "bubble.left")
                            .font(.title2)
                        Text("留言")
                            .font(.caption)
                    }
                }
                .foregroundColor(.white)
            }
            .padding(.top, 10)    // 增加顶部间距
            .padding(.bottom, 80)  // 减少底部间距，原来是 50

            Color.clear
                .frame(height: 20) // 为底部导航栏预留空间
        }
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.bottom)
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