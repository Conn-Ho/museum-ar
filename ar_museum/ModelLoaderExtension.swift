import RealityKit
import Foundation

extension ModelEntity {
    static func loadModel(named name: String) throws -> ModelEntity {
        // 方法1：直接从Bundle中加载
        if let url = Bundle.main.url(forResource: name, withExtension: "usdz") {
            do {
                let entity = try Entity.load(contentsOf: url)
                // 转换为ModelEntity
                if let modelEntity = entity as? ModelEntity {
                    return modelEntity
                } else {
                    let modelEntity = ModelEntity()
                    modelEntity.addChild(entity)
                    return modelEntity
                }
            } catch {
                print("加载模型失败: \(error.localizedDescription)")
                throw error
            }
        }
        
        // 方法2：尝试从assets目录加载
        if let url = Bundle.main.url(forResource: name, withExtension: "usdz", subdirectory: "assets") {
            do {
                let entity = try Entity.load(contentsOf: url)
                // 转换为ModelEntity
                if let modelEntity = entity as? ModelEntity {
                    return modelEntity
                } else {
                    let modelEntity = ModelEntity()
                    modelEntity.addChild(entity)
                    return modelEntity
                }
            } catch {
                print("从assets目录加载模型失败: \(error.localizedDescription)")
                throw error
            }
        }
        
        throw NSError(domain: "ModelLoading", code: 404, userInfo: [NSLocalizedDescriptionKey: "找不到模型: \(name).usdz"])
    }
} 