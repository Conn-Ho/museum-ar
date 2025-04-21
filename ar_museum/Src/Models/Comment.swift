import Foundation

struct Comment: Identifiable {
    let id = UUID()
    let username: String
    let content: String
    let timestamp: Date
    
    // 格式化时间显示
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
} 