import SwiftUI

struct NearbyMessagesView: View {
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(.white)
                
                Text("附近有\(count)条留言")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(20)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NearbyMessagesListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var messageManager: ARMessageManager
    
    let messages: [ARMessage]
    @Binding var selectedMessage: ARMessage?
    @Binding var showMessageDetail: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(messages) { message in
                    Button(action: {
                        selectedMessage = message
                        showMessageDetail = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            // 消息类型图标
                            Image(systemName: messageTypeIcon(for: message.type))
                                .foregroundColor(messageTypeColor(for: message.type))
                                .font(.title2)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading) {
                                Text(message.authorName)
                                    .font(.headline)
                                
                                Text(messagePreview(for: message))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("附近的留言")
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func messageTypeIcon(for type: ARMessage.MessageType) -> String {
        switch type {
        case .text:
            return "text.bubble.fill"
        case .audio:
            return "waveform.circle.fill"
        case .drawing:
            return "pencil.tip.crop.circle.fill"
        }
    }
    
    private func messageTypeColor(for type: ARMessage.MessageType) -> Color {
        switch type {
        case .text:
            return .blue
        case .audio:
            return .green
        case .drawing:
            return .orange
        }
    }
    
    private func messagePreview(for message: ARMessage) -> String {
        switch message.type {
        case .text:
            return message.content.count > 30 ? message.content.prefix(30) + "..." : message.content
        case .audio:
            return "语音留言"
        case .drawing:
            return "涂鸦留言"
        }
    }
} 