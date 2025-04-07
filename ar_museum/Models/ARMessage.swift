import Foundation
import SwiftUI
import RealityKit

struct ARMessage: Identifiable, Codable {
    let id: UUID
    let authorName: String
    let content: String
    let type: MessageType
    let position: MessagePosition
    let createdAt: Date
    let audioURL: URL?
    let drawingData: Data?
    
    enum MessageType: String, Codable {
        case text
        case audio
        case drawing
    }
    
    struct MessagePosition: Codable {
        let x: Float
        let y: Float
        let z: Float
        
        var simdPosition: SIMD3<Float> {
            SIMD3<Float>(x, y, z)
        }
    }
    
    init(id: UUID = UUID(), 
         authorName: String, 
         content: String, 
         type: MessageType, 
         position: SIMD3<Float>, 
         createdAt: Date = Date(), 
         audioURL: URL? = nil, 
         drawingData: Data? = nil) {
        self.id = id
        self.authorName = authorName
        self.content = content
        self.type = type
        self.position = MessagePosition(x: position.x, y: position.y, z: position.z)
        self.createdAt = createdAt
        self.audioURL = audioURL
        self.drawingData = drawingData
    }
}

// 消息管理器
class ARMessageManager: ObservableObject {
    @Published var messages: [ARMessage] = []
    
    // 从本地存储加载消息
    func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "arMessages") {
            do {
                let decoder = JSONDecoder()
                messages = try decoder.decode([ARMessage].self, from: data)
            } catch {
                print("无法加载留言: \(error)")
            }
        }
    }
    
    // 保存消息到本地存储
    func saveMessages() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: "arMessages")
        } catch {
            print("无法保存留言: \(error)")
        }
    }
    
    // 添加新消息
    func addMessage(_ message: ARMessage) {
        messages.append(message)
        saveMessages()
    }
    
    // 删除消息
    func deleteMessage(id: UUID) {
        messages.removeAll { $0.id == id }
        saveMessages()
    }
    
    // 获取特定区域内的消息
    func messagesNearPosition(_ position: SIMD3<Float>, radius: Float = 5.0) -> [ARMessage] {
        return messages.filter { message in
            let messagePos = message.position.simdPosition
            let distance = length(messagePos - position)
            return distance <= radius
        }
    }
} 