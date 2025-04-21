import SceneKit
import SwiftUI
import AVFoundation

class VirtualMuseumViewModel: NSObject, ObservableObject, SCNSceneRendererDelegate {
    let cameraHeight: Float = 5.0  // 移除 private
    
    @Published var scene: SCNScene
    @Published var cameraNode: SCNNode
    @Published var showExhibitDetail = false
    @Published var showGalleryList = false
    @Published var selectedExhibit: Exhibit?
    @Published var galleries: [Gallery] = []
    
    private var lastPanLocation: CGPoint?
    private var audioPlayer: AVAudioPlayer?
    var sceneView: SCNView?
    
    // 添加碰撞检测相关属性
    private let collisionCategory_camera: Int = 1
    private let collisionCategory_wall: Int = 2
    private let cameraCollisionShape: SCNPhysicsShape
    
    // 添加展品位置字典
    private let exhibitPositions: [String: (position: SCNVector3, info: String)] = [
        "terracotta1": (
            position: SCNVector3(x: -5, y: 0, z: -5),
            info: "这是秦始皇兵马俑，是世界第八大奇迹..."
        ),
        "vase1": (
            position: SCNVector3(x: 5, y: 0, z: -5),
            info: "这是汉代青铜器，展现了..."
        )
        // 可以添加更多展品位置
    ]
    
    // 添加视角控制的敏感度
    private let rotationSensitivity: Float = 0.005
    
    // 添加一个常量定义最大交互距离
    private let maxInteractionDistance: Float = 5.0
    
    // 更新展品标记数组
    private var exhibitMarkers: [ExhibitMarker] = [
        ExhibitMarker(
            position: SCNVector3(x: -5, y: 2.0, z: -5),
            title: "秦始皇兵马俑",
            description: """
                兵马俑是世界第八大奇迹，被誉为"世界上最伟大的考古发现之一"。
                
                这些陶俑是按照真人大小制作的，每个俑的面部表情、服饰、发型都各不相同。它们的发现为我们展示了秦朝强大的军事力量和精湛的制作工艺。
                
                兵马俑于1974年被陕西临潼县杨家村的农民在打井时意外发现。考古发掘证实这是秦始皇陵的陪葬坑，共有三个兵马俑坑，总面积达22000多平方米。
                """,
            viewingPosition: SCNVector3(x: -5, y: 2.5, z: -2),
            viewingRotation: SCNVector3(x: 0, y: 0, z: 0)
        ),
        ExhibitMarker(
            position: SCNVector3(x: 5, y: 2.0, z: -5),
            title: "商代青铜鼎",
            description: """
                青铜鼎是中国古代最重要的礼器之一，象征着权力与地位。
                
                这件青铜鼎采用失蜡法铸造，器身纹饰精美，具有典型的商代晚期青铜器特征。鼎身上的饕餮纹展现了商代青铜器独特的艺术风格。
                
                青铜鼎不仅是重要的礼器，也是烹饪器具，在古代祭祀、宴飨等重要场合中扮演着关键角色。它的制作工艺展现了商代高超的冶金技术。
                """,
            viewingPosition: SCNVector3(x: 5, y: 2.5, z: -2),
            viewingRotation: SCNVector3(x: 0, y: 0, z: 0)
        )
    ]
    
    override init() {
        scene = SCNScene()
        cameraNode = SCNNode()
        
        // 初始化相机碰撞形状
        let capsuleGeometry = SCNCapsule(capRadius: 0.2, height: 1.6)
        cameraCollisionShape = SCNPhysicsShape(geometry: capsuleGeometry, options: nil)
        
        super.init()
        
        setupScene()
        setupCamera()
        setupLighting()
        loadMuseumModel()
        setupGalleries()
        setupInteraction()
        setupPhysics()
        setupExhibitMarkers()  // 添加新方法
    }
    
    private func setupScene() {
        // // 添加调试用的参考物体，帮助确认场景是否正确加载
        // let debugBox = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        // let debugNode = SCNNode(geometry: debugBox)
        // debugNode.position = SCNVector3(0, 0, 0)
        // let material = SCNMaterial()
        // material.diffuse.contents = UIColor.red
        // debugBox.materials = [material]
        // scene.rootNode.addChildNode(debugNode)
        
        // 修改模型加载逻辑
        let modelFiles = [
            "museum2": (position: SCNVector3(-10, -5, 2), scale: 0.1),  // 尝试缩小模型
        ]
        
        // 打印Bundle信息以便调试
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        for (modelName, config) in modelFiles {
            // 尝试多个可能的路径
            let possiblePaths = [
                "Resources/Models",
                "Models",
                "",
                "assets"
            ]
            
            var loadedModel = false
            
            for path in possiblePaths {
                if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: path) {
                    do {
                        print("Attempting to load model from: \(modelURL.path)")
                        let modelScene = try SCNScene(url: modelURL, options: [
                            .checkConsistency: true,
                            .convertToYUp: true
                        ])
                        
                        if let modelNode = modelScene.rootNode.childNodes.first {
                            modelNode.name = modelName
                            modelNode.position = config.position
                            modelNode.scale = SCNVector3(config.scale, config.scale, config.scale)
                            
                            // 打印模型信息
                            print("Model loaded: \(modelName)")
                            print("Model bounds: \(modelNode.boundingBox)")
                            print("Model position: \(modelNode.position)")
                            
                            scene.rootNode.addChildNode(modelNode)
                            loadedModel = true
                            break
                        }
                    } catch {
                        print("Error loading model \(modelName) from \(path): \(error)")
                    }
                }
            }
            
            if !loadedModel {
                print("Failed to load model: \(modelName)")
            }
        }
    }
    
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        // 设置初始相机位置
        cameraNode.position = SCNVector3(0, cameraHeight, 5)
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        // 增强环境光照
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 1000  // 增加光照强度
        ambientLight.light?.temperature = 6500  // 添加色温
        scene.rootNode.addChildNode(ambientLight)
        
        // 添加多个方向光源
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1000
        directionalLight.position = SCNVector3(0, 10, 10)
        directionalLight.eulerAngles = SCNVector3(-Float.pi/4, 0, 0)
        scene.rootNode.addChildNode(directionalLight)
        
        // 添加额外的补光
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.intensity = 500
        fillLight.position = SCNVector3(-5, 5, 5)
        scene.rootNode.addChildNode(fillLight)
    }
    
    private func loadMuseumModel() {
    // 使用 Bundle.main.url 来获取资源文件路径
    if let museumURL = Bundle.main.url(forResource: "museum2", withExtension: "usdz", subdirectory: "Resources/Models") {
        do {
            let museumScene = try SCNScene(url: museumURL, options: [
                .checkConsistency: true,
                .convertToYUp: true
            ])
            scene.rootNode.addChildNode(museumScene.rootNode)
        } catch {
            print("Error loading museum model: \(error)")
        }
    }
    
    if let terracottaURL = Bundle.main.url(forResource: "terracotta", withExtension: "usdz", subdirectory: "Resources/Models") {
        do {
            let terracottaScene = try SCNScene(url: terracottaURL, options: [
                .checkConsistency: true,
                .convertToYUp: true
            ])
            scene.rootNode.addChildNode(terracottaScene.rootNode)
        } catch {
            print("Error loading terracotta model: \(error)")
        }
    }
}
    
    private func setupGalleries() {
        galleries = [
            Gallery(name: "秦代展厅", cameraPosition: SCNVector3(0, 2.5, 5), cameraRotation: SCNVector3(0, 0, 0)),
            Gallery(name: "汉代展厅", cameraPosition: SCNVector3(10, 2.5, 5), cameraRotation: SCNVector3(0, Float.pi/2, 0)),
            Gallery(name: "唐代展厅", cameraPosition: SCNVector3(-10, 2.5, 5), cameraRotation: SCNVector3(0, -Float.pi/2, 0))
        ]
    }
    
    private func setupInteraction() {
        // 移除重复的物理体设置
        // cameraNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
    }
    
    private func setupPhysics() {
        // 设置场景的物理世界
        scene.physicsWorld.gravity = SCNVector3(0, -9.81, 0)
        scene.physicsWorld.contactDelegate = self
        
        // 为所有可能的墙壁和物体添加物理体
        addPhysicsBodies()
    }
    
    private func addPhysicsBodies() {
        // 为博物馆模型添加物理体
        scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "museum1" || node.name?.contains("wall") == true {
                // 为墙壁创建物理体
                let physicsShape = SCNPhysicsShape(node: node, options: [
                    .type: SCNPhysicsShape.ShapeType.concavePolyhedron,
                    .keepAsCompound: true
                ])
                
                let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
                physicsBody.categoryBitMask = PhysicsCategory.wall
                physicsBody.collisionBitMask = PhysicsCategory.camera
                physicsBody.friction = 0.5
                physicsBody.restitution = 0.0
                node.physicsBody = physicsBody
            }
        }
    }
    
    private func setupExhibitMarkers() {
        for marker in exhibitMarkers {
            // 创建标记节点
            let markerNode = SCNNode()
            
            // 创建一个更明显的标记
            let boxGeometry = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.1)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.yellow
            material.emission.contents = UIColor.yellow
            material.transparency = 0.8
            boxGeometry.materials = [material]
            
            markerNode.geometry = boxGeometry
            markerNode.position = marker.position
            markerNode.name = "marker-\(marker.id)"
            
            // 添加持续旋转动画
            let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 3)
            let forever = SCNAction.repeatForever(rotation)
            markerNode.runAction(forever)
            
            scene.rootNode.addChildNode(markerNode)
            print("Added marker: \(marker.title) at position: \(marker.position)")
        }
    }
    
    // MARK: - Interaction Handlers
    
    func handlePan(_ value: DragGesture.Value) {
        guard let lastLocation = lastPanLocation else {
            lastPanLocation = value.location
            return
        }
        
        let deltaX = Float(value.location.x - lastLocation.x)
        let deltaY = Float(value.location.y - lastLocation.y)
        
        // 水平旋转 - 调整敏感度
        cameraNode.eulerAngles.y -= deltaX * rotationSensitivity
        
        // 垂直旋转（限制角度）
        let currentAngleX = cameraNode.eulerAngles.x
        let newAngleX = currentAngleX - deltaY * rotationSensitivity
        // 限制垂直旋转范围在 -45° 到 45° 之间
        cameraNode.eulerAngles.x = max(-Float.pi/4, min(Float.pi/4, newAngleX))
        
        lastPanLocation = value.location
    }
    
    func handlePanEnd(_ value: DragGesture.Value) {
        lastPanLocation = nil
    }
    
    func handlePinch(_ scale: CGFloat) {
        if let exhibit = selectedExhibit,
           let node = exhibit.node {  // 安全解包 node
            let newScale = Float(scale)
            node.scale = SCNVector3(newScale, newScale, newScale)
        }
    }
    
    func handleRotation(_ angle: Angle) {
        if let exhibit = selectedExhibit,
           let node = exhibit.node {  // 安全解包 node
            node.eulerAngles.y = Float(angle.radians)
        }
    }
    
    func handleJoystickMovement(direction: CGPoint) {
        let speed: Float = 0.3
        
        // 获取相机的前向量和右向量
        let rotation = cameraNode.eulerAngles
        
        // 计算相机的前向量（考虑只要水平方向的旋转）
        let forwardX = sin(rotation.y)
        let forwardZ = cos(rotation.y)
        
        // 计算相机的右向量（垂直于前向量）
        let rightX = cos(rotation.y)
        let rightZ = -sin(rotation.y)
        
        // 将摇杆输入转换为移动向量
        // direction.y 控制前后移动（负值是前进，正值是后退）
        // direction.x 控制左右移动（负值是左移，正值是右移）
        let moveForward = Float(direction.y) * speed
        let moveRight = Float(direction.x) * speed
        
        // 合并前后和左右移动
        let dx = (forwardX * moveForward) + (rightX * moveRight)
        let dz = (forwardZ * moveForward) + (rightZ * moveRight)
        
        // 更新相机位置
        let newPosition = SCNVector3(
            cameraNode.position.x + dx,
            cameraNode.position.y,
            cameraNode.position.z + dz
        )
        
        // 设置新位置
        cameraNode.position = newPosition
        
        // 打印调试信息
        print("Moving: forward/back: \(moveForward), right/left: \(moveRight)")
    }
    
    // 添加辅助方法来计算两点之间的距离
    private func distance(from point1: SCNVector3, to point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }
    
    func switchGallery(to gallery: Gallery) {
        showGalleryList = false
        
        // 使用动画切换视角
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        
        cameraNode.position = gallery.cameraPosition
        cameraNode.eulerAngles = gallery.cameraRotation
        
        SCNTransaction.commit()
    }
    
    // MARK: - Exhibit Interaction
    
    func handleExhibitTap(at point: CGPoint) {
        guard let sceneView = sceneView else { return }
        
        let hitResults = sceneView.hitTest(point, options: [:])
        
        if let result = hitResults.first {
            let node = result.node
            
            // 向上遍历节点层级来查找父节点
            var currentNode: SCNNode? = node
            while let parent = currentNode {
                if parent.name == "terracotta" {
                    let detailScene = createDetailScene(for: parent)
                    selectedExhibit = Exhibit(
                        title: "秦始皇兵马俑",
                        description: "兵马俑，又称秦始皇兵马俑，是世界第八大奇迹...",
                        audioURL: Bundle.main.url(forResource: "terracotta_audio", withExtension: "mp3"),
                        node: parent,
                        detailScene: detailScene
                    )
                    showExhibitDetail = true
                    break
                }
                currentNode = parent.parent
            }
        }
    }
    
    private func createDetailScene(for node: SCNNode) -> SCNScene {
        let detailScene = SCNScene()
        
        // 复制展品节点
        let exhibitCopy = node.clone()
        exhibitCopy.position = SCNVector3(0, 0, 0)
        detailScene.rootNode.addChildNode(exhibitCopy)
        
        // 添加光照
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 100
        detailScene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.position = SCNVector3(5, 5, 5)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        detailScene.rootNode.addChildNode(directionalLight)
        
        return detailScene
    }
    
    // 添加一个方法来重置展品状态
    private func resetExhibitState() {
        self.selectedExhibit = nil
        self.showExhibitDetail = false
    }
    
    func handleSceneTap(at point: CGPoint) {
        guard let sceneView = sceneView else { return }
        print("Tap detected at: \(point)")
        
        resetExhibitState()
        
        let hitResults = sceneView.hitTest(point, options: nil)
        print("Hit results count: \(hitResults.count)")
        
        for result in hitResults {
            let node = result.node
            print("Hit node name: \(node.name ?? "unnamed")")
            
            // 获取点击位置的世界坐标
            let hitPosition = result.worldCoordinates
            print("Hit position: \(hitPosition)")
            
            // 首先检查是否直接点击了标记
            if let nodeName = node.name,
               nodeName.starts(with: "marker-") {
                // 找到最近的标记
                let markerPosition = hitPosition
                if let nearestMarker = findNearestMarker(to: markerPosition, maxDistance: maxInteractionDistance) {
                    print("Directly hit marker, moving to: \(nearestMarker.title)")
                    moveToExhibit(marker: nearestMarker)
                    return
                }
            }
            
            // 如果点击了展品
            if let nodeName = node.name,
               nodeName.starts(with: "Object_") {
                if let nearestMarker = findNearestMarker(to: hitPosition, maxDistance: maxInteractionDistance) {
                    print("Moving to nearest marker: \(nearestMarker.title)")
                    moveToExhibit(marker: nearestMarker)
                    return
                }
            }
        }
    }
    
    private func moveToExhibit(marker: ExhibitMarker) {
        guard let cameraNode = sceneView?.pointOfView else { return }
        
        // 创建动画
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        
        // 设置相机位置和旋转
        cameraNode.position = marker.viewingPosition
        cameraNode.eulerAngles = marker.viewingRotation
        
        SCNTransaction.completionBlock = { [weak self] in
            guard let self = self else { return }
            
            // 创建并显示展品信息
            DispatchQueue.main.async {
                self.selectedExhibit = Exhibit(
                    title: marker.title,
                    description: marker.description
                )
                self.showExhibitDetail = true
                print("Showing exhibit detail for: \(marker.title)")
            }
        }
        
        SCNTransaction.commit()
    }
    
    private func findNearestMarker(to position: SCNVector3, maxDistance: Float) -> ExhibitMarker? {
        var nearestMarker: ExhibitMarker?
        var shortestDistance: Float = Float.infinity
        
        for marker in exhibitMarkers {
            let dist = distance(from: position, to: marker.position)
            print("Distance to marker '\(marker.title)': \(dist)")
            
            if dist < shortestDistance && dist <= maxInteractionDistance {
                shortestDistance = dist
                nearestMarker = marker
            }
        }
        
        if let marker = nearestMarker {
            print("Found nearest marker: \(marker.title) at distance: \(shortestDistance)")
        }
        
        return nearestMarker
    }
    
    // 添加调试方法
    private func printDebugInfo(for marker: ExhibitMarker) {
        print("Debug Info for Marker:")
        print("Title: \(marker.title)")
        print("Position: \(marker.position)")
        print("Viewing Position: \(marker.viewingPosition)")
        print("Viewing Rotation: \(marker.viewingRotation)")
        print("Description length: \(marker.description.count) characters")
    }
}

// 添加 SCNPhysicsContactDelegate 扩展
extension VirtualMuseumViewModel: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // 处理碰撞开始事件
        if (contact.nodeA.physicsBody?.categoryBitMask == collisionCategory_camera ||
            contact.nodeB.physicsBody?.categoryBitMask == collisionCategory_camera) {
            // 相机与墙壁发生碰撞
            print("Camera collision detected")
        }
    }
}

// 添加向量计算的辅助扩展
extension SCNVector3 {
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }
}

// 添加物理碰撞常量
private struct PhysicsCategory {
    static let none      = 0
    static let camera    = 1
    static let wall      = 2
    static let all       = Int.max
} 