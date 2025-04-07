import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("enableNotifications") private var enableNotifications: Bool = true
    @AppStorage("preferredLanguage") private var preferredLanguage: String = "中文"
    @State private var showResetAlert = false
    
    let languages = ["中文", "English", "日本語", "Français", "Español"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("个人信息")) {
                    TextField("用户名", text: $userName)
                }
                
                Section(header: Text("应用设置")) {
                    Toggle("启用通知", isOn: $enableNotifications)
                    
                    Picker("语言", selection: $preferredLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                }
                
                Section(header: Text("缓存管理")) {
                    HStack {
                        Text("缓存大小")
                        Spacer()
                        Text("128MB")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // 清除缓存逻辑
                    }) {
                        Text("清除缓存")
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        Text("恢复默认设置")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Text("关于我们")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("隐私政策")
                    }
                }
            }
            .navigationTitle("设置")
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("恢复默认设置"),
                    message: Text("确定要恢复所有设置到默认状态吗？此操作无法撤销。"),
                    primaryButton: .destructive(Text("恢复")) {
                        // 重置设置逻辑
                        userName = ""
                        enableNotifications = true
                        preferredLanguage = "中文"
                    },
                    secondaryButton: .cancel(Text("取消"))
                )
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AR博物馆")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("版本 1.0.0")
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("AR博物馆是一款基于iOS平台的虚实结合博物馆导览系统，通过3D虚拟博物馆和AR增强现实技术，为用户提供高互动性、高沉浸感的观展体验。")
                    .lineSpacing(6)
                
                Text("开发团队")
                    .font(.headline)
                    .padding(.top)
                
                Text("ConnHo - 项目负责人\n技术支持团队\n设计团队\n内容策划团队")
                
                Text("联系我们")
                    .font(.headline)
                    .padding(.top)
                
                Text("邮箱: support@armuseum.com\n网站: www.armuseum.com")
            }
            .padding()
        }
        .navigationTitle("关于我们")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("隐私政策")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("最后更新: 2025年3月22日")
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("本隐私政策描述了我们在您使用AR博物馆应用时如何收集、使用和共享您的个人信息。")
                    .lineSpacing(6)
                
                Group {
                    Text("信息收集")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("我们可能收集以下类型的信息:\n• 设备信息: 包括设备型号、操作系统版本等\n• 使用数据: 应用使用频率、功能偏好等\n• 位置信息: 仅在您使用AR功能时，用于提供准确的AR体验")
                    
                    Text("信息使用")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("我们使用收集的信息来:\n• 提供、维护和改进我们的服务\n• 开发新功能和服务\n• 理解用户如何使用我们的应用")
                    
                    Text("信息共享")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("我们不会出售您的个人信息。我们可能在以下情况下共享您的信息:\n• 经您同意\n• 遵守法律要求\n• 与我们的服务提供商合作，他们帮助我们提供服务")
                }
            }
            .padding()
        }
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 