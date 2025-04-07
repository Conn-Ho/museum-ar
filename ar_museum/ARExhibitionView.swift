import SwiftUI
import RealityKit
import ARKit

struct ARExhibitionView: View {
    @State private var selectedExhibit: Exhibit?
    @State private var showExhibitPicker = false
    
    init() {
        // 打印Bundle中的所有资源
        printBundleContents()
    }
    
    func printBundleContents() {
        let fm = FileManager.default
        let bundlePath = Bundle.main.bundlePath
        
        print("Bundle路径: \(bundlePath)")
        
        do {
            let items = try fm.contentsOfDirectory(atPath: bundlePath)
            print("Bundle包含以下文件:")
            for item in items {
                print("- \(item)")
                
                // 如果是目录，继续列出子目录内容
                let itemPath = bundlePath + "/" + item
                var isDir: ObjCBool = false
                if fm.fileExists(atPath: itemPath, isDirectory: &isDir), isDir.boolValue {
                    do {
                        let subItems = try fm.contentsOfDirectory(atPath: itemPath)
                        for subItem in subItems {
                            print("  - \(item)/\(subItem)")
                        }
                    } catch {
                        print("  无法列出子目录内容: \(error)")
                    }
                }
            }
        } catch {
            print("无法列出Bundle内容: \(error)")
        }
        
        // 特别检查"兵马俑.usdz"文件
        if let path = Bundle.main.path(forResource: "兵马俑", ofType: "usdz") {
            print("找到兵马俑.usdz文件: \(path)")
        } else {
            print("找不到兵马俑.usdz文件")
        }
        
        if let path = Bundle.main.path(forResource: "兵马俑", ofType: "usdz", inDirectory: "assets") {
            print("在assets目录中找到兵马俑.usdz文件: \(path)")
        } else {
            print("在assets目录中找不到兵马俑.usdz文件")
        }
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(selectedExhibit: $selectedExhibit)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { showExhibitPicker = true }) {
                        Text("选择展品")
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Spacer()
                
                if let exhibit = selectedExhibit {
                    ExhibitInfoCard(exhibit: exhibit)
                        .padding()
                } else {
                    Text("请选择一个展品放置在平面上")
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            
            if showExhibitPicker {
                ExhibitPickerView(isPresented: $showExhibitPicker, selectedExhibit: $selectedExhibit)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedExhibit: Exhibit?
    
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
        context.coordinator.selectedExhibit = selectedExhibit
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        var view: ARView?
        var selectedExhibit: Exhibit?
        var placedEntity: ModelEntity?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = self.view, let exhibit = selectedExhibit else { return }
            
            let tapLocation = gesture.location(in: view)
            let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let result = results.first {
                // 创建锚点 - 修复初始化方法
                let anchor = AnchorEntity()
                anchor.transform = Transform(matrix: result.worldTransform)
                
                // 如果已经有放置的实体，先移除
                if let placedEntity = placedEntity {
                    placedEntity.removeFromParent()
                }
                
                // 加载3D模型
                if let modelEntity = loadExhibitModel(exhibit) {
                    placedEntity = modelEntity
                    anchor.addChild(modelEntity)
                    view.scene.addAnchor(anchor)
                }
            }
        }
        
        func loadExhibitModel(_ exhibit: Exhibit) -> ModelEntity? {
            guard let modelName = exhibit.modelName else {
                // 如果没有模型名称，创建一个默认几何体
                let mesh = MeshResource.generateBox(size: 0.2, cornerRadius: 0.01)
                let material = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: true)
                let entity = ModelEntity(mesh: mesh, materials: [material])
                addInfoLabel(to: entity, text: exhibit.name)
                return entity
            }
            
            // 直接使用exhibit的modelURL属性
            if let modelURL = exhibit.modelURL {
                do {
                    print("尝试加载模型: \(modelURL.path)")
                    let entity = try Entity.load(contentsOf: modelURL)
                    
                    // 转换为ModelEntity
                    let modelEntity: ModelEntity
                    if let entityAsModel = entity as? ModelEntity {
                        modelEntity = entityAsModel
                    } else {
                        modelEntity = ModelEntity()
                        modelEntity.addChild(entity)
                    }
                    
                    // 调整模型大小和位置
                    let boundingBox = modelEntity.visualBounds(relativeTo: nil)
                    let maxDimension = max(boundingBox.extents.x, max(boundingBox.extents.y, boundingBox.extents.z))
                    let scale: Float = 0.2 / maxDimension  // 将模型缩放到合适大小
                    modelEntity.scale = SIMD3<Float>(repeating: scale)
                    
                    // 确保模型底部与平面对齐
                    modelEntity.position.y = boundingBox.extents.y / 2 * scale
                    
                    // 添加信息标签
                    addInfoLabel(to: modelEntity, text: exhibit.name)
                    
                    print("模型加载成功")
                    return modelEntity
                } catch {
                    print("无法加载模型 \(modelURL.path): \(error.localizedDescription)")
                }
            } else {
                print("找不到模型URL: \(modelName)")
            }
            
            // 加载失败时使用默认几何体
            let mesh = MeshResource.generateBox(size: 0.2, cornerRadius: 0.01)
            let material = SimpleMaterial(color: .red, roughness: 0.5, isMetallic: true)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            addInfoLabel(to: entity, text: "\(exhibit.name)\n(模型加载失败)")
            return entity
        }
        
        func addInfoLabel(to entity: ModelEntity, text: String) {
            // 创建文本实体
            let mesh = MeshResource.generateText(text,
                                               extrusionDepth: 0.01,
                                               font: .systemFont(ofSize: 0.05),
                                               containerFrame: .zero,
                                               alignment: .center,
                                               lineBreakMode: .byTruncatingTail)
            
            let material = SimpleMaterial(color: .white, roughness: 0, isMetallic: false)
            let textEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // 放置在主实体上方
            textEntity.position = [0, 0.15, 0]
            textEntity.scale = [0.5, 0.5, 0.5]
            
            entity.addChild(textEntity)
        }
    }
} 