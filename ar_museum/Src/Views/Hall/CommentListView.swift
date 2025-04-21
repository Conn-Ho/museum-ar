import SwiftUI

struct CommentListView: View {
    let exhibitId: UUID
    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @State private var isLoading = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 留言列表
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(comments) { comment in
                        CommentCell(comment: comment)
                    }
                }
                .padding()
            }
            
            // 留言输入区域
            VStack(spacing: 8) {
                Divider()
                    .background(Color.white)
                
                HStack {
                    TextField("写下你的想法...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)
                        .focused($isInputFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            submitComment()
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: submitComment) {
                        Text("发送")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(newComment.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(UIColor.systemBackground).opacity(0.1))
        }
        .onAppear(perform: loadComments)
    }
    
    private func loadComments() {
        isLoading = true
        // 模拟加载评论
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            comments = [
                Comment(username: "访客1", content: "这件展品太震撼了！", timestamp: Date()),
                Comment(username: "访客2", content: "第一次看到实物，比照片更有感觉。", timestamp: Date().addingTimeInterval(-3600)),
                Comment(username: "访客3", content: "希望能多了解一些历史背景。", timestamp: Date().addingTimeInterval(-7200))
            ]
            isLoading = false
        }
    }
    
    private func submitComment() {
        guard !newComment.isEmpty else { return }
        
        // 创建新评论
        let comment = Comment(username: "我", content: newComment, timestamp: Date())
        comments.insert(comment, at: 0)
        
        // 清空输入框并收起键盘
        newComment = ""
        isInputFocused = false
    }
}

// 单个评论单元格视图
struct CommentCell: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.username)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(comment.formattedTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(comment.content)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
} 