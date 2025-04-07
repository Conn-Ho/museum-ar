import Foundation
import SwiftUI
import RealityKit

struct Exhibit: Identifiable {
    let id: String
    let name: String
    let description: String
    let period: String
    let category: String
    let thumbnailImage: String
    let detailImages: [String]
    let hasARModel: Bool
    let modelName: String?
    let modelURL: URL?
    let audioGuideURL: URL?
    let isEnvironment: Bool
    
    // 展品位置信息（用于虚拟博物馆中定位）
    let museumLocation: MuseumLocation?
    
    init(id: String, 
         name: String, 
         description: String, 
         period: String, 
         category: String, 
         thumbnailImage: String, 
         detailImages: [String], 
         hasARModel: Bool, 
         modelName: String?, 
         audioGuideURL: URL? = nil, 
         isEnvironment: Bool = false, 
         museumLocation: MuseumLocation? = nil) {
        
        self.id = id
        self.name = name
        self.description = description
        self.period = period
        self.category = category
        self.thumbnailImage = thumbnailImage
        self.detailImages = detailImages
        self.hasARModel = hasARModel
        self.modelName = modelName
        self.audioGuideURL = audioGuideURL
        self.isEnvironment = isEnvironment
        self.museumLocation = museumLocation
        
        // 设置模型URL
        if let modelName = modelName {
            self.modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz")
        } else {
            self.modelURL = nil
        }
    }
}

struct MuseumLocation {
    let hall: String
    let floor: Int
    let position: SIMD3<Float> // 3D坐标
}

// 示例数据
let sampleExhibits = [
    Exhibit(
        id: "001",
        name: "秦始皇兵马俑",
        description: "秦始皇兵马俑是世界上规模最大的地下军事博物馆，这些陶俑是按照真人大小制作的，每一个都有独特的面部特征和表情。",
        period: "秦朝 (公元前221-207年)",
        category: "陶俑",
        thumbnailImage: "兵马俑",
        detailImages: ["terracotta_warrior_1", "terracotta_warrior_2"],
        hasARModel: true,
        modelName: "兵马俑",
        audioGuideURL: URL(string: "https://example.com/audio/001"),
        isEnvironment: false,
        museumLocation: MuseumLocation(hall: "中国古代文明厅", floor: 1, position: SIMD3<Float>(10.5, 0, 15.2))
    ),
    Exhibit(
        id: "002",
        name: "虚拟博物馆",
        description: "这是一个完整的虚拟博物馆环境，您可以在其中漫游并欣赏各种展品。",
        period: "现代",
        category: "环境",
        thumbnailImage: "museum_thumb",
        detailImages: ["museum_1"],
        hasARModel: true,
        modelName: "Floor",
        audioGuideURL: nil,
        isEnvironment: true, // 标记为环境模型
        museumLocation: nil
    ),
    Exhibit(
        id: "003",
        name: "莫奈睡莲",
        description: "《睡莲》是法国印象派画家克洛德·莫奈晚年的代表作品系列。这些作品捕捉了莫奈花园中睡莲池塘在不同光线和季节下的变化。",
        period: "1914-1926年",
        category: "绘画",
        thumbnailImage: "monet_waterlilies_thumb",
        detailImages: ["monet_waterlilies_1"],
        hasARModel: true,
        modelName: "Floor",
        audioGuideURL: URL(string: "https://example.com/audio/002"),
        isEnvironment: false,
        museumLocation: MuseumLocation(hall: "西方艺术厅", floor: 2, position: SIMD3<Float>(25.3, 3.0, 12.8))
    ),
    Exhibit(
        id: "004",
        name: "埃及法老面具",
        description: "图坦卡蒙黄金面具是古埃及最著名的文物之一，由纯金制成，镶嵌有彩色玻璃和宝石。这个面具是为年轻的法老图坦卡蒙制作的殓葬面具。",
        period: "公元前1323年",
        category: "面具",
        thumbnailImage: "pharaoh_mask_thumb",
        detailImages: ["pharaoh_mask_1"],
        hasARModel: true,
        modelName: "pharaoh_mask",
        audioGuideURL: URL(string: "https://example.com/audio/003"),
        isEnvironment: false,
        museumLocation: MuseumLocation(hall: "古埃及文明厅", floor: 1, position: SIMD3<Float>(15.7, 0, 22.3))
    ),
    // 可以根据您提供的USDZ模型添加更多展品...
] 
