import SceneKit
import SwiftUI
import AVFoundation

class VirtualMuseumViewModel: ObservableObject {
    @Published var scene: SCNScene
    @Published var cameraNode: SCNNode
    @Published var showExhibitDetail = false
    @Published var showGalleryList = false
    @Published var selectedExhibit: Exhibit?
    @Published var galleries: [Gallery] = []
    
    private var lastPanLocation: CGPoint?
    private var audioPlayer: AVAudioPlayer?
    private var sceneView: SCNView?
    
    init() {
        scene = SCNScene()
        cameraNode = SCNNode()
        
        setupScene()
        setupCamera()
        setupLighting()
        loadMuseumModel()
        setupGalleries()
        setupInteraction()
    }
    
    private func setupScene() {
        // 添加调试用的参考物体，帮助确认场景是否正确加载
        let debugBox = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let debugNode = SCNNode(geometry: debugBox)
        debugNode.position = SCNVector3(0, 0, 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        debugBox.materials = [material]
        scene.rootNode.addChildNode(debugNode)
        
        // 修改模型加载逻辑
        let modelFiles = [
            "Floor": (position: SCNVector3(0, -1, 0), scale: 1.0),
            "museum1": (position: SCNVector3(0, 0, 0), scale: 0.1),  // 尝试缩小模型
            "terracotta": (position: SCNVector3(2, 0, -2), scale: 0.05)  // 尝试缩小模型
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
        // 调整相机初始位置，拉远一些以便看到整个场景
        cameraNode.position = SCNVector3(0, 2, 10)  // 更改位置
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 1000  // 增加远平面距离
        cameraNode.camera?.fieldOfView = 60  // 设置视场角
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
    if let museumURL = Bundle.main.url(forResource: "museum", withExtension: "usdz", subdirectory: "Resources/Models") {
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
            Gallery(name: "秦代展厅", cameraPosition: SCNVector3(0, 1.7, 5), cameraRotation: SCNVector3(0, 0, 0)),
            Gallery(name: "汉代展厅", cameraPosition: SCNVector3(10, 1.7, 5), cameraRotation: SCNVector3(0, Float.pi/2, 0)),
            Gallery(name: "唐代展厅", cameraPosition: SCNVector3(-10, 1.7, 5), cameraRotation: SCNVector3(0, -Float.pi/2, 0))
        ]
    }
    
    private func setupInteraction() {
        // 添加碰撞检测
        cameraNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
    }
    
    // MARK: - Interaction Handlers
    
    func handlePan(_ value: DragGesture.Value) {
        guard let lastLocation = lastPanLocation else {
            lastPanLocation = value.location
            return
        }
        
        let deltaX = Float(value.location.x - lastLocation.x)
        let deltaY = Float(value.location.y - lastLocation.y)
        
        // 水平旋转
        cameraNode.eulerAngles.y -= deltaX * 0.01
        
        // 垂直旋转（限制角度）
        let currentAngleX = cameraNode.eulerAngles.x
        let newAngleX = currentAngleX - deltaY * 0.01
        cameraNode.eulerAngles.x = max(-Float.pi/4, min(Float.pi/4, newAngleX))
        
        lastPanLocation = value.location
    }
    
    func handlePanEnd(_ value: DragGesture.Value) {
        lastPanLocation = nil
    }
    
    func handlePinch(_ scale: CGFloat) {
        if let exhibit = selectedExhibit {
            let newScale = Float(scale)
            exhibit.node.scale = SCNVector3(newScale, newScale, newScale)
        }
    }
    
    func handleRotation(_ angle: Angle) {
        if let exhibit = selectedExhibit {
            exhibit.node.eulerAngles.y = Float(angle.radians)
        }
    }
    
    func handleJoystickMovement(direction: CGPoint) {
        let speed: Float = 0.1
        let moveX = Float(direction.x) * speed
        let moveZ = Float(direction.y) * speed
        
        // 根据相机朝向计算移动方向
        let currentRotationY = cameraNode.eulerAngles.y
        let dx = moveX * cos(currentRotationY) - moveZ * sin(currentRotationY)
        let dz = moveX * sin(currentRotationY) + moveZ * cos(currentRotationY)
        
        // 检查移动是否会导致碰撞
        let newPosition = SCNVector3(
            cameraNode.position.x + dx,
            cameraNode.position.y,
            cameraNode.position.z + dz
        )
        
        // 进行射线检测，确保不会穿墙
        let from = cameraNode.position
        let to = newPosition
        
        // Use physics world for ray testing
        let results = scene.physicsWorld.rayTestWithSegment(
            from: from,
            to: to,
            options: [SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.closest]
        )
        
        if results.isEmpty {
            cameraNode.position = newPosition
        }
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
    
    // Add method to set scene view
    func setSceneView(_ view: SCNView) {
        self.sceneView = view
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
                    selectedExhibit = Exhibit(
                        node: parent,
                        detailScene: createDetailScene(for: parent),
                        description: "兵马俑，又称秦始皇兵马俑，是世界第八大奇迹...",
                        audioURL: Bundle.main.url(forResource: "terracotta_audio", withExtension: "mp3")
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
    
    // 添加辅助方法来创建物理边界（防止穿墙）
    private func addPhysicsBodies() {
        // 为博物馆墙壁添加物理边界
        if let museumNode = scene.rootNode.childNode(withName: "museum1", recursively: true) {
            let physicsShape = SCNPhysicsShape(node: museumNode, options: [
                SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron
            ])
            museumNode.physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        }
    }
} 