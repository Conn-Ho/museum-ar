import Foundation
import SceneKit

struct ExhibitMarker: Identifiable {
    let id = UUID()
    let position: SCNVector3      // 3D空间中的位置
    let title: String            // 展品名称
    let description: String      // 展品描述
    let viewingPosition: SCNVector3  // 观看位置（相机应该移动到的位置）
    let viewingRotation: SCNVector3  // 观看角度
} 