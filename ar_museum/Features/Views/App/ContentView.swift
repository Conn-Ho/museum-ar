import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页/探索
            NavigationView {
                VStack {
                    Text("探索博物馆")
                        .font(.largeTitle)
                        .bold()
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            // 展览预览卡片
                            ForEach(0..<4) { index in
                                ExhibitionCard(
                                    title: "展览 \(index + 1)",
                                    imageSystemName: "photo",
                                    description: "这是一个精彩的展览介绍"
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .tabItem {
                Label("探索", systemImage: "building.columns")
            }
            .tag(0)
            
            // AR体验
            NavigationView {
                Text("AR体验")
                    .navigationTitle("AR")
            }
            .tabItem {
                Label("AR", systemImage: "camera.viewfinder")
            }
            .tag(1)

            // AR留言墙
            NavigationView {
                Text("AR留言墙")
                    .navigationTitle("AR")
            }
            .tabItem {
                Label("留言墙", systemImage: "bubble.left")
            }
            .tag(3)
            
            // 我的
            NavigationView {
                List {
                    Section(header: Text("个人信息")) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("游客")
                                    .font(.headline)
                                Text("点击登录")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("功能")) {
                        NavigationLink(destination: Text("收藏展品")) {
                            Label("收藏展品", systemImage: "star")
                        }
                        
                        NavigationLink(destination: Text("浏览历史")) {
                            Label("浏览历史", systemImage: "clock")
                        }
                        
                        NavigationLink(destination: Text("设置")) {
                            Label("设置", systemImage: "gear")
                        }
                    }
                }
                .navigationTitle("我的")
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
            .tag(2)
        }
    }
}

// 展览卡片视图
struct ExhibitionCard: View {
    let title: String
    let imageSystemName: String
    let description: String
    
    var body: some View {
        VStack {
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .foregroundColor(.blue)
                .padding()
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // 处理点击事件
            }) {
                Text("了解更多")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
} 