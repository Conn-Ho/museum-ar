import RealityKit
import ARKit
import Combine

class ARExhibitViewModel: NSObject, ObservableObject {
    weak var arView: ARView?
    private var currentEntity: Entity?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadModel(exhibit: ARExhibit) {
        isLoading = true
        
        if let modelURL = Bundle.main.url(forResource: exhibit.modelName, 
                                        withExtension: "usdz") {
            do {
                let loadedEntity = try Entity.load(contentsOf: modelURL)
                loadedEntity.scale = [exhibit.scale, exhibit.scale, exhibit.scale]
                self.currentEntity = loadedEntity
                isLoading = false
                print("\(exhibit.name) 模型加载成功")
            } catch {
                print("加载模型失败: \(error)")
                errorMessage = "加载模型失败: \(error.localizedDescription)"
                isLoading = false
            }
        } else {
            print("无法找到模型文件: \(exhibit.modelName)")
            errorMessage = "无法找到模型文件"
            isLoading = false
        }
    }
    
    func handleTap(at point: CGPoint) {
        guard let arView = arView,
              let entity = self.currentEntity else { return }
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let transform = firstResult.worldTransform
            let position = simd_make_float3(transform.columns.3)
            
            let anchorEntity = AnchorEntity(world: position)
            let modelClone = entity.clone(recursive: true)
            
            modelClone.position.y += 0.01
            modelClone.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
            
            anchorEntity.addChild(modelClone)
            resetScene()
            arView.scene.addAnchor(anchorEntity)
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