import SceneKit

struct Exhibit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let audioURL: URL?
    
    // 可选属性，用于3D展示时
    let node: SCNNode?
    let detailScene: SCNScene?
    
    init(title: String, description: String, audioURL: URL? = nil, node: SCNNode? = nil, detailScene: SCNScene? = nil) {
        self.title = title
        self.description = description
        self.audioURL = audioURL
        self.node = node
        self.detailScene = detailScene
    }
}
