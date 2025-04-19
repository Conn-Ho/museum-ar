import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页/探索
            NavigationView {
                VirtualMuseumView()
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
            .tag(2)
            
            // 我的
            NavigationView {
               ProfileView()
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
            .tag(3)
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