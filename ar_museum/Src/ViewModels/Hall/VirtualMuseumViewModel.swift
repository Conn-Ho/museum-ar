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
        // 加载博物馆 USDZ 模型
        if let museumURL = Bundle.main.url(forResource: "museum", withExtension: "usdz") {
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
    }
    
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1.7, 5) // 人眼高度
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLighting() {
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 100
        scene.rootNode.addChildNode(ambientLight)
        
        // 定向光
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.position = SCNVector3(0, 10, 0)
        directionalLight.eulerAngles = SCNVector3(-Float.pi/4, 0, 0)
        scene.rootNode.addChildNode(directionalLight)
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
        
        // Create a ray node for collision testing
        let rayNode = SCNNode()
        let rayGeometry = SCNCylinder(radius: 0.1, height: 0.5)
        rayNode.geometry = rayGeometry
        rayNode.position = cameraNode.position
        
        // Add physics body to ray node
        rayNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: rayGeometry))
        rayNode.physicsBody?.isAffectedByGravity = false
        rayNode.physicsBody?.categoryBitMask = 2  // Different from camera's category
        
        // Add ray to scene temporarily
        scene.rootNode.addChildNode(rayNode)
        
        // Test for contact
        let contacts = scene.physicsWorld.contactTest(with: rayNode.physicsBody!)
        
        // Remove ray node after testing
        rayNode.removeFromParentNode()
        
        // If no collisions detected, allow movement
        if contacts.isEmpty {
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
            if let exhibitNode = result.node.parent, exhibitNode.name == "terracotta" {
                selectedExhibit = Exhibit(
                    node: exhibitNode,
                    detailScene: createDetailScene(for: exhibitNode),
                    description: "兵马俑，又称秦始皇兵马俑，是世界第八大奇迹...",
                    audioURL: Bundle.main.url(forResource: "terracotta_audio", withExtension: "mp3")
                )
                showExhibitDetail = true
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
} 