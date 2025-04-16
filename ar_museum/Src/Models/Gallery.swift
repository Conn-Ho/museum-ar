import SceneKit
import Foundation
import SwiftUI
// 数据模型
struct Gallery: Identifiable {
    let id = UUID()
    let name: String
    let cameraPosition: SCNVector3
    let cameraRotation: SCNVector3
}
