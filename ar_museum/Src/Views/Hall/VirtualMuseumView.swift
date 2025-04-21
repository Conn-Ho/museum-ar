import SceneKit
import SwiftUI
import Combine

struct VirtualMuseumView: View {
    @StateObject private var viewModel = VirtualMuseumViewModel()

    var body: some View {
        ZStack {
            SceneKitView(viewModel: viewModel)  // 新建的自定义 UIViewRepresentable
                .edgesIgnoringSafeArea(.all)
            
            // 虚拟摇杆控制
            VirtualJoystickView(
                onDirectionChanged: viewModel.handleJoystickMovement
            )
            .frame(width: 200, height: 200)
            .position(
                x: UIScreen.main.bounds.width - 120,
                y: UIScreen.main.bounds.height - 250
            )
            
            // 展厅切换按钮
            Button(action: { viewModel.showGalleryList.toggle() }) {
                Image(systemName: "list.bullet")
                    .font(.title)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            .position(x: UIScreen.main.bounds.width - 50, y: 50)
            
            // 展品详情半屏弹窗
            if viewModel.showExhibitDetail, let exhibit = viewModel.selectedExhibit {
                VStack {
                    Spacer()
                    ExhibitDetailView(
                        exhibit: exhibit,
                        isPresented: $viewModel.showExhibitDetail
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                    .transition(.move(edge: .bottom))
                }
                .animation(.spring(), value: viewModel.showExhibitDetail)
            }
        }
        .sheet(isPresented: $viewModel.showGalleryList) {
            NavigationView {
                GalleryListView(galleries: viewModel.galleries) { gallery in
                    viewModel.switchGallery(to: gallery)
                }
                .navigationBarItems(
                    trailing: Button("关闭") {
                        viewModel.showGalleryList = false
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// 添加新的 SceneKit 视图包装器
struct SceneKitView: UIViewRepresentable {
    let viewModel: VirtualMuseumViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = viewModel.scene
        scnView.pointOfView = viewModel.cameraNode
        scnView.delegate = viewModel
        scnView.backgroundColor = .black
        
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // 添加平移手势识别器
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        // 保存 SCNView 引用
        viewModel.sceneView = scnView
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // 更新视图
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject {
        let viewModel: VirtualMuseumViewModel
        private var lastPanLocation: CGPoint?
        
        init(viewModel: VirtualMuseumViewModel) {
            self.viewModel = viewModel
        }
        
        @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
            let location = gestureRecognize.location(in: gestureRecognize.view)
            viewModel.handleSceneTap(at: location)
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                lastPanLocation = gesture.location(in: gesture.view)
                
            case .changed:
                guard let lastLocation = lastPanLocation else { return }
                let location = gesture.location(in: gesture.view)
                
                let deltaX = Float(location.x - lastLocation.x)
                let deltaY = Float(location.y - lastLocation.y)
                
                // 水平旋转
                viewModel.cameraNode.eulerAngles.y -= deltaX * 0.005
                
                // 垂直旋转（限制角度）
                let currentAngleX = viewModel.cameraNode.eulerAngles.x
                let newAngleX = currentAngleX - deltaY * 0.005
                viewModel.cameraNode.eulerAngles.x = max(-Float.pi/4, min(Float.pi/4, newAngleX))
                
                lastPanLocation = location
                
            case .ended, .cancelled:
                lastPanLocation = nil
                
            default:
                break
            }
        }
    }
}

// 添加 UIViewRepresentable 扩展来获取底层 UIView
extension View {
    var view: UIView? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let viewHost = window.rootViewController?.view.subviews.first else {
            return nil
        }
        return viewHost
    }
}
