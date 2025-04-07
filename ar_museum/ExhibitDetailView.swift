import SwiftUI
import AVKit

struct ExhibitDetailView: View {
    let exhibit: Exhibit
    @State private var showARView = false
    @State private var isPlayingAudio = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 图片轮播
                TabView {
                    ForEach(exhibit.detailImages, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
                
                VStack(alignment: .leading, spacing: 16) {
                    // 标题和时期
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exhibit.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(exhibit.period)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 操作按钮
                    HStack {
                        if exhibit.hasARModel {
                            Button(action: { showARView = true }) {
                                Label("AR查看", systemImage: "arkit")
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if exhibit.audioGuideURL != nil {
                            Button(action: toggleAudio) {
                                Label(isPlayingAudio ? "暂停讲解" : "语音讲解", 
                                      systemImage: isPlayingAudio ? "pause.circle" : "play.circle")
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Button(action: {
                            // 添加到收藏
                        }) {
                            Label("收藏", systemImage: "heart")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Divider()
                    
                    // 详细描述
                    Text("展品介绍")
                        .font(.headline)
                    
                    Text(exhibit.description)
                        .lineSpacing(6)
                    
                    // 博物馆位置
                    if let location = exhibit.museumLocation {
                        Divider()
                        
                        Text("博物馆位置")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("展厅: \(location.hall)")
                                Text("楼层: \(location.floor)层")
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // 在虚拟博物馆中导航到此展品
                            }) {
                                Label("导航", systemImage: "map")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showARView) {
            if let modelName = exhibit.modelName {
                SingleExhibitARView(modelName: modelName, exhibitName: exhibit.name)
            }
        }
        .onDisappear {
            // 停止音频播放
            audioPlayer?.stop()
            isPlayingAudio = false
        }
    }
    
    func toggleAudio() {
        if isPlayingAudio {
            audioPlayer?.pause()
            isPlayingAudio = false
        } else {
            if audioPlayer == nil, let audioURL = exhibit.audioGuideURL {
                // 加载音频
                do {
                    let data = try Data(contentsOf: audioURL)
                    audioPlayer = try AVAudioPlayer(data: data)
                    audioPlayer?.prepareToPlay()
                } catch {
                    print("无法加载音频: \(error)")
                }
            }
            
            audioPlayer?.play()
            isPlayingAudio = true
        }
    }
} 