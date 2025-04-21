import RealityKit
import ARKit
import Combine

class ARExhibitViewModel: NSObject, ObservableObject {
    weak var arView: ARView?
    private var cancellables = Set<AnyCancellable>()
    private var terracottaEntity: Entity?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        loadTerracottaModel()
    }
    
    private func loadTerracottaModel() {
        isLoading = true
        
        if let modelURL = Bundle.main.url(forResource: "terracotta", 
                                        withExtension: "usdz") {
            do {
                let loadedEntity = try Entity.load(contentsOf: modelURL)
                // 将缩放比例改得更小
                loadedEntity.scale = [0.001, 0.001, 0.001]  // 从 0.05 改为 0.001
                self.terracottaEntity = loadedEntity
                isLoading = false
                print("兵马俑模型加载成功")
            } catch {
                print("加载兵马俑模型失败: \(error)")
                errorMessage = "加载模型失败: \(error.localizedDescription)"
                isLoading = false
            }
        } else {
            print("无法找到兵马俑模型文件")
            errorMessage = "无法找到兵马俑模型文件"
            isLoading = false
        }
    }
    
    func handleTap(at point: CGPoint) {
        guard let arView = arView,
              let terracottaEntity = self.terracottaEntity else { return }
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let transform = firstResult.worldTransform
            let position = simd_make_float3(transform.columns.3)
            
            let anchorEntity = AnchorEntity(world: position)
            let modelClone = terracottaEntity.clone(recursive: true)
            
            // 调整模型的位置，稍微抬高一点，避免陷入平面
            modelClone.position.y += 0.01  // 向上抬高1厘米
            
            // 调整模型朝向
            modelClone.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
            
            anchorEntity.addChild(modelClone)
            resetScene()
            arView.scene.addAnchor(anchorEntity)
            
            print("兵马俑已放置在位置: \(position)")
        }
    }
    
    func resetScene() {
        // 清除现有的锚点和模型
        arView?.scene.anchors.removeAll()
    }
}

// ARSession代理扩展
extension ARExhibitViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                print("检测到平面: \(planeAnchor)")
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        errorMessage = "AR会话失败: \(error.localizedDescription)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR会话被中断")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR会话中断结束")
        resetScene()
    }
} 