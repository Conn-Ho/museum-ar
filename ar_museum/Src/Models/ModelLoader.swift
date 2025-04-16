import Foundation
import RealityKit

class ModelLoader {
    static let shared = ModelLoader()
    
    private init() {}
    
    func loadModel(named modelName: String) -> ModelEntity? {
        do {
            let modelEntity = try Entity.load(named: modelName)
            // 将 Entity 转换为 ModelEntity
            if let modelEntity = modelEntity as? ModelEntity {
                return modelEntity
            } else {
                print("Failed to convert \(modelName) to ModelEntity")
                return nil
            }
        } catch {
            print("Failed to load model \(modelName): \(error.localizedDescription)")
            return nil
        }
    }
}