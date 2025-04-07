import SwiftUI
import RealityKit
import SceneKit

struct VirtualMuseumView: View {
    @State private var currentLocation = "入口大厅"
    @State private var showMap = false
    @State private var playerPosition = SIMD3<Float>(0, 1.7, 0)
    @State private var playerRotation: Float = 0
    @State private var showMessageCreation = false
    @State private var showMessageDetail = false
    @State private var selectedMessage: ARMessage?
    @State private var showNearbyMessagesAlert = false
    @State private var nearbyMessagesCount = 0
    
    @StateObject private var messageManager = ARMessageManager()
    
    var body: some View {
        ZStack {
            // 3D虚拟博物馆场景
            VirtualMuseumSceneView(
                playerPosition: $playerPosition,
                playerRotation: $playerRotation,
                showMessageCreation: $showMessageCreation,
                showMessageDetail: $showMessageDetail,
                selectedMessage: $selectedMessage
            )
            .environmentObject(messageManager)
            .edgesIgnoringSafeArea(.all)
            
            // 界面控制元素
            VStack {
                HStack {
                    Text("当前位置: \(currentLocation)")
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    // 附近留言提示
                    if nearbyMessagesCount > 0 {
                        Text("附近有\(nearbyMessagesCount)条留言")
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { showMap.toggle() }) {
                        Image(systemName: "map")
                            .font(.title)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer()
                
                // 导航控制
                HStack {
                    NavigationButton(direction: "左转", icon: "arrow.left") {
                        playerRotation -= 0.2
                    }
                    
                    NavigationButton(direction: "前进", icon: "arrow.up") {
                        // 计算前进方向
                        let forwardX = sin(playerRotation)
                        let forwardZ = cos(playerRotation)
                        
                        // 更新位置
                        playerPosition.x += forwardX * 0.5
                        playerPosition.z += forwardZ * 0.5
                    }
                    
                    NavigationButton(direction: "右转", icon: "arrow.right") {
                        playerRotation += 0.2
                    }
                }
                .padding(.bottom, 30)
            }
            
            // 博物馆地图弹窗
            if showMap {
                MuseumMapView(isPresented: $showMap, currentLocation: $currentLocation)
            }
            
            // 留言创建弹窗
            if showMessageCreation {
                ARMessageCreationView(position: playerPosition)
                    .environmentObject(messageManager)
                    .transition(.opacity)
                    .onDisappear {
                        showMessageCreation = false
                    }
            }
            
            // 留言详情弹窗
            if showMessageDetail, let message = selectedMessage {
                ARMessageDetailView(message: message)
                    .environmentObject(messageManager)
                    .transition(.opacity)
                    .onDisappear {
                        showMessageDetail = false
                        selectedMessage = nil
                    }
            }
        }
        .onAppear {
            // 加载保存的留言
            messageManager.loadMessages()
        }
    }
}

struct NavigationButton: View {
    let direction: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                Text(direction)
                    .font(.caption)
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct VirtualMuseumSceneView: UIViewRepresentable {
    @Binding var playerPosition: SIMD3<Float>
    @Binding var playerRotation: Float
    @Binding var showMessageCreation: Bool
    @Binding var showMessageDetail: Bool
    @Binding var selectedMessage: ARMessage?
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene(named: "MuseumScene.scn")
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .black
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // 更新玩家位置和旋转
        let scene = uiView.scene
        if let playerNode = scene?.rootNode.childNode(withName: "Player", recursively: true) {
            playerNode.position = SCNVector3(playerPosition.x, playerPosition.y, playerPosition.z)
            playerNode.eulerAngles = SCNVector3(0, playerRotation, 0)
        }
    }
} 