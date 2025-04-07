import SwiftUI
import RealityKit
import Combine

struct VirtualMuseumSceneView: UIViewRepresentable {
    @Binding var playerPosition: SIMD3<Float>
    @Binding var playerRotation: Float
    @EnvironmentObject var messageManager: ARMessageManager
    @Binding var showMessageCreation: Bool
    @Binding var showMessageDetail: Bool
    @Binding var selectedMessage: ARMessage?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 禁用AR功能，我们只需要3D渲染
        arView.automaticallyConfigureSession = false
        
        // 加载博物馆环境模型
        if let museumExhibit = sampleExhibits.first(where: { $0.isEnvironment }),
           let modelURL = museumExhibit.modelURL {
            do {
                let entity = try Entity.load(contentsOf: modelURL)
                
                // 创建场景锚点
                let anchor = AnchorEntity()
                anchor.addChild(entity)
                
                // 调整模型大小 - 对于环境模型，我们使用更大的缩放
                entity.scale = SIMD3<Float>(repeating: 5.0) // 根据需要调整缩放比例
                
                // 添加到场景
                arView.scene.addAnchor(anchor)
                
                // 创建相机实体
                let camera = PerspectiveCamera()
                camera.camera.fieldOfViewInDegrees = 60
                
                // 创建相机锚点
                let cameraAnchor = AnchorEntity()
                cameraAnchor.addChild(camera)
                arView.scene.addAnchor(cameraAnchor)
                
                // 保存引用
                context.coordinator.view = arView
                context.coordinator.camera = camera
                context.coordinator.cameraAnchor = cameraAnchor
                
                // 添加展品
                addExhibits(to: arView.scene)
                
                // 添加留言墙标记
                addMessageWalls(to: arView.scene)
                
                // 添加留言
                context.coordinator.addMessages(to: arView.scene)
                
                // 添加点击手势
                let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
                arView.addGestureRecognizer(tapGesture)
                
            } catch {
                print("无法加载博物馆环境模型: \(error)")
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 更新相机位置和旋转
        if let cameraAnchor = context.coordinator.cameraAnchor {
            // 设置位置
            cameraAnchor.position = playerPosition
            
            // 设置旋转 - 围绕Y轴旋转
            let rotation = simd_quatf(angle: playerRotation, axis: SIMD3<Float>(0, 1, 0))
            cameraAnchor.orientation = rotation
        }
        
        // 检查是否有新消息需要添加
        if context.coordinator.messageCount != messageManager.messages.count {
            context.coordinator.updateMessages(in: uiView.scene)
        }
        
        // 检查附近的留言
        context.coordinator.checkNearbyMessages(playerPosition: playerPosition)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 添加展品到场景
    func addExhibits(to scene: RealityKit.Scene) {
        // 过滤出非环境的展品
        let exhibits = sampleExhibits.filter { !$0.isEnvironment && $0.hasARModel && $0.modelName != nil }
        
        for exhibit in exhibits {
            guard let modelName = exhibit.modelName,
                  let location = exhibit.museumLocation else { continue }
            
            do {
                let modelEntity = try ModelEntity.loadModel(named: modelName)
                
                // 调整大小
                let boundingBox = modelEntity.visualBounds(relativeTo: nil)
                let maxDimension = max(boundingBox.extents.x, max(boundingBox.extents.y, boundingBox.extents.z))
                let scale: Float = 0.5 / maxDimension  // 适当的大小
                modelEntity.scale = SIMD3<Float>(repeating: scale)
                
                // 放置在指定位置
                let anchor = AnchorEntity()
                anchor.position = location.position
                anchor.addChild(modelEntity)
                
                // 添加信息标签
                addInfoLabel(to: modelEntity, text: exhibit.name)
                
                scene.addAnchor(anchor)
            } catch {
                print("无法加载展品模型 \(modelName): \(error)")
            }
        }
    }
    
    // 添加留言墙标记
    func addMessageWalls(to scene: RealityKit.Scene) {
        // 定义留言墙位置
        let messageWallLocations = [
            SIMD3<Float>(12.0, 1.5, 10.0),  // 入口大厅
            SIMD3<Float>(20.0, 1.5, 15.0),  // 中国古代文明厅
            SIMD3<Float>(25.0, 4.5, 12.0)   // 西方艺术厅
        ]
        
        for location in messageWallLocations {
            // 创建留言墙标记
            let mesh = MeshResource.generatePlane(width: 2.0, depth: 1.5)
            let material = SimpleMaterial(color: .blue.withAlphaComponent(0.3), roughness: 0.3, isMetallic: true)
            let wallEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // 放置在指定位置
            let anchor = AnchorEntity()
            anchor.position = location
            anchor.addChild(wallEntity)
            
            // 添加标签
            addInfoLabel(to: wallEntity, text: "AR留言墙\n点击添加留言")
            
            // 添加到场景
            scene.addAnchor(anchor)
        }
    }
    
    // 添加信息标签
    func addInfoLabel(to entity: ModelEntity, text: String) {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.05),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        
        let material = SimpleMaterial(color: .white, roughness: 0, isMetallic: false)
        let textEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // 放置在主实体上方
        textEntity.position = [0, 0.3, 0]
        textEntity.scale = [0.5, 0.5, 0.5]
        
        entity.addChild(textEntity)
    }
    
    class Coordinator {
        var parent: VirtualMuseumSceneView
        var view: ARView?
        var camera: PerspectiveCamera?
        var cameraAnchor: AnchorEntity?
        var messageEntities: [UUID: Entity] = [:]
        var messageCount: Int = 0
        var nearbyMessages: [ARMessage] = []
        
        init(_ parent: VirtualMuseumSceneView) {
            self.parent = parent
        }
        
        func addMessages(to scene: RealityKit.Scene) {
            guard let view = view else { return }
            
            for message in parent.messageManager.messages {
                addMessageEntity(message, to: scene)
            }
            
            messageCount = parent.messageManager.messages.count
        }
        
        func updateMessages(in scene: RealityKit.Scene) {
            // 移除所有现有消息实体
            for (_, entity) in messageEntities {
                entity.removeFromParent()
            }
            messageEntities.removeAll()
            
            // 重新添加所有消息
            addMessages(to: scene)
        }
        
        func addMessageEntity(_ message: ARMessage, to scene: RealityKit.Scene) {
            // 创建消息标记
            let mesh: MeshResource
            let material: Material
            
            switch message.type {
            case .text:
                mesh = MeshResource.generateSphere(radius: 0.2)
                material = SimpleMaterial(color: .blue, roughness: 0.3, isMetallic: true)
            case .audio:
                mesh = MeshResource.generateSphere(radius: 0.2)
                material = SimpleMaterial(color: .green, roughness: 0.3, isMetallic: true)
            case .drawing:
                mesh = MeshResource.generateSphere(radius: 0.2)
                material = SimpleMaterial(color: .orange, roughness: 0.3, isMetallic: true)
            }
            
            let messageEntity = ModelEntity(mesh: mesh, materials: [material])
            messageEntity.name = message.id.uuidString
            
            // 添加标签
            let labelText = "\(message.authorName)的留言"
            addLabel(to: messageEntity, text: labelText)
            
            // 放置在指定位置
            let anchor = AnchorEntity()
            anchor.position = message.position.simdPosition
            anchor.addChild(messageEntity)
            
            // 添加到场景
            scene.addAnchor(anchor)
            
            // 保存引用
            messageEntities[message.id] = anchor
        }
        
        func addLabel(to entity: ModelEntity, text: String) {
            let mesh = MeshResource.generateText(
                text,
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 0.05),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
            
            let material = SimpleMaterial(color: .white, roughness: 0, isMetallic: false)
            let textEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // 放置在主实体上方
            textEntity.position = [0, 0.3, 0]
            textEntity.scale = [0.5, 0.5, 0.5]
            
            entity.addChild(textEntity)
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = view else { return }
            
            let tapLocation = gesture.location(in: view)
            let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
            
            if let result = results.first,
               let entity = result.entity as? ModelEntity {
                
                // 检查是否点击了留言墙
                if entity.name.isEmpty && entity.components[ModelComponent.self] != nil {
                    // 点击了留言墙，显示创建留言界面
                    DispatchQueue.main.async {
                        self.parent.showMessageCreation = true
                    }
                }
                // 检查是否点击了留言
                else if let messageId = UUID(uuidString: entity.name),
                        let message = parent.messageManager.messages.first(where: { $0.id == messageId }) {
                    // 点击了留言，显示留言详情
                    DispatchQueue.main.async {
                        self.parent.selectedMessage = message
                        self.parent.showMessageDetail = true
                    }
                }
            }
        }
        
        func checkNearbyMessages(playerPosition: SIMD3<Float>) {
            // 获取附近的留言
            let nearby = parent.messageManager.messagesNearPosition(playerPosition, radius: 3.0)
            
            // 如果附近留言发生变化，更新UI
            if nearby.count != nearbyMessages.count || !nearby.map({ $0.id }).elementsEqual(nearbyMessages.map({ $0.id })) {
                nearbyMessages = nearby
                
                // 通知UI更新
                DispatchQueue.main.async {
                    // 这里可以触发UI更新，例如显示附近有新留言的提示
                    // 在VirtualMuseumView中处理
                }
            }
        }
    }
} 