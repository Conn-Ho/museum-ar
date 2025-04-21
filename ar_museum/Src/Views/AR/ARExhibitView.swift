import SwiftUI
import ARKit
import RealityKit

struct ARExhibitView: View {
    @StateObject private var viewModel = ARExhibitViewModel()
    
    var body: some View {
        ZStack {
            // AR视图
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            // 提示信息
            VStack {
                if viewModel.isLoading {
                    Text("正在加载兵马俑模型...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                } else {
                    Text("点击平面放置兵马俑")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.top)
                }
                
                Spacer()
                
                // 底部工具栏
                HStack {
                    Button(action: {
                        viewModel.resetScene()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            
            // 错误提示
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
            }
        }
    }
}

// AR视图容器
struct ARViewContainer: UIViewRepresentable {
    let viewModel: ARExhibitViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 配置AR会话
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // 设置代理
        arView.session.delegate = viewModel
        
        // 存储AR视图引用
        viewModel.arView = arView
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject {
        let viewModel: ARExhibitViewModel
        
        init(viewModel: ARExhibitViewModel) {
            self.viewModel = viewModel
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARView else { return }
            let location = gesture.location(in: arView)
            viewModel.handleTap(at: location)
        }
    }
} 