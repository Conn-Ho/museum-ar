import SwiftUI
import RealityKit
import ARKit

struct SingleExhibitARView: View {
    let modelName: String
    let exhibitName: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            ARViewContainer(modelName: modelName)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text(exhibitName)
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                Text("点击屏幕放置展品")
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            }
        }
    }
    
    // 这个ARViewContainer是专门为单个展品设计的，与ARExhibitionView中的不同
    struct ARViewContainer: UIViewRepresentable {
        let modelName: String
        
        func makeUIView(context: Context) -> ARView {
            let arView = ARView(frame: .zero)
            
            // 配置AR会话
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            arView.session.run(config)
            
            // 添加手势识别
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
            arView.addGestureRecognizer(tapGesture)
            
            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
            context.coordinator.view = uiView
            context.coordinator.modelName = modelName
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject {
            var parent: ARViewContainer
            var view: ARView?
            var modelName: String?
            var placedEntity: ModelEntity?
            
            init(_ parent: ARViewContainer) {
                self.parent = parent
                self.modelName = parent.modelName
            }
            
            @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                guard let view = self.view, let modelName = modelName else { return }
                
                let tapLocation = gesture.location(in: view)
                let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
                
                if let result = results.first {
                    // 创建锚点
                    let anchor = AnchorEntity()
                    anchor.transform = Transform(matrix: result.worldTransform)
                    
                    // 如果已经有放置的实体，先移除
                    if let placedEntity = placedEntity {
                        placedEntity.removeFromParent()
                    }
                    
                    // 加载3D模型
                    if let modelEntity = loadModel(modelName) {
                        placedEntity = modelEntity
                        anchor.addChild(modelEntity)
                        view.scene.addAnchor(anchor)
                    }
                }
            }
            
            func loadModel(_ name: String) -> ModelEntity? {
                do {
                    // 尝试加载USDZ模型
                    let modelEntity = try ModelEntity.loadModel(named: name)
                    
                    // 调整模型大小和位置
                    let boundingBox = modelEntity.visualBounds(relativeTo: nil)
                    let maxDimension = max(boundingBox.extents.x, max(boundingBox.extents.y, boundingBox.extents.z))
                    let scale: Float = 0.2 / maxDimension  // 将模型缩放到合适大小
                    modelEntity.scale = SIMD3<Float>(repeating: scale)
                    
                    // 确保模型底部与平面对齐
                    modelEntity.position.y = boundingBox.extents.y / 2 * scale
                    
                    return modelEntity
                } catch {
                    print("无法加载模型 \(name): \(error.localizedDescription)")
                    
                    // 加载失败时使用默认几何体
                    let mesh = MeshResource.generateBox(size: 0.2, cornerRadius: 0.01)
                    let material = SimpleMaterial(color: .red, roughness: 0.5, isMetallic: true)
                    return ModelEntity(mesh: mesh, materials: [material])
                }
            }
        }
    }
} 