import Foundation

struct ARExhibit: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let modelName: String
    let scale: Float
    
    static func == (lhs: ARExhibit, rhs: ARExhibit) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let samples = [
        ARExhibit(
            name: "秦始皇兵马俑",
            description: "世界第八大奇迹",
            modelName: "terracotta",
            scale: 0.001
        ),
        ARExhibit(
            name: "铁壶",
            description: "商周时期青铜器",
            modelName: "pot",
            scale: 0.002
        ),
        ARExhibit(
            name: "铜器",
            description: "铜制供器",
            modelName: "铜制供器",
            scale: 0.002
        ),
        ARExhibit(
            name: "文物",
            description: "文物",
            modelName: "文物",
            scale: 0.002
        ),
        ARExhibit(
            name: "铜镜",
            description: "铜镜",
            modelName: "Gamontai Shinjukyo Mirror",
            scale: 0.002
        )
    ]
}