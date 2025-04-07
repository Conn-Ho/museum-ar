import SwiftUI
import AVFoundation
import PencilKit

struct ARMessageCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var messageManager: ARMessageManager
    
    let position: SIMD3<Float>
    
    @State private var authorName: String = ""
    @State private var messageContent: String = ""
    @State private var selectedType: ARMessage.MessageType = .text
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    @State private var canvasView = PKCanvasView()
    @State private var drawingData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("留言信息")) {
                    TextField("您的名字", text: $authorName)
                    
                    Picker("留言类型", selection: $selectedType) {
                        Text("文字").tag(ARMessage.MessageType.text)
                        Text("语音").tag(ARMessage.MessageType.audio)
                        Text("涂鸦").tag(ARMessage.MessageType.drawing)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("留言内容")) {
                    if selectedType == .text {
                        TextEditor(text: $messageContent)
                            .frame(height: 150)
                    } else if selectedType == .audio {
                        VStack {
                            if isRecording {
                                Text("正在录音...")
                                    .foregroundColor(.red)
                            } else if audioURL != nil {
                                Text("录音完成")
                                    .foregroundColor(.green)
                            }
                            
                            Button(action: {
                                if isRecording {
                                    stopRecording()
                                } else {
                                    startRecording()
                                }
                            }) {
                                Text(isRecording ? "停止录音" : "开始录音")
                                    .padding()
                                    .background(isRecording ? Color.red : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            if audioURL != nil {
                                Button("播放录音") {
                                    playRecording()
                                }
                                .padding(.top)
                            }
                        }
                        .padding()
                    } else if selectedType == .drawing {
                        DrawingView(canvasView: $canvasView, drawingData: $drawingData)
                            .frame(height: 300)
                    }
                }
            }
            .navigationTitle("创建AR留言")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveMessage()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isValidMessage())
            )
        }
        .onAppear {
            // 从UserDefaults加载用户名
            authorName = UserDefaults.standard.string(forKey: "userName") ?? ""
            setupAudioSession()
        }
    }
    
    private func isValidMessage() -> Bool {
        switch selectedType {
        case .text:
            return !authorName.isEmpty && !messageContent.isEmpty
        case .audio:
            return !authorName.isEmpty && audioURL != nil
        case .drawing:
            return !authorName.isEmpty && drawingData != nil
        }
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
    }
    
    private func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("录音失败: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        audioURL = audioRecorder?.url
    }
    
    private func playRecording() {
        guard let url = audioURL else { return }
        
        let player = AVPlayer(url: url)
        player.play()
    }
    
    private func saveMessage() {
        var content = messageContent
        
        if selectedType == .audio {
            content = "语音留言"
        } else if selectedType == .drawing {
            content = "涂鸦留言"
        }
        
        // 保存绘图数据
        if selectedType == .drawing {
            drawingData = canvasView.drawing.dataRepresentation()
        }
        
        let message = ARMessage(
            authorName: authorName,
            content: content,
            type: selectedType,
            position: position,
            audioURL: audioURL,
            drawingData: drawingData
        )
        
        messageManager.addMessage(message)
        
        // 保存用户名到UserDefaults
        UserDefaults.standard.set(authorName, forKey: "userName")
    }
}

struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawingData: Data?
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = .white
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView
        
        init(_ parent: DrawingView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawingData = canvasView.drawing.dataRepresentation()
        }
    }
} 