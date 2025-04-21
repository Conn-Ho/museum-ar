import SwiftUI
import ARKit
import RealityKit

struct ARExhibitView: View {
    @StateObject private var viewModel = ARExhibitViewModel()
    @State private var showExhibitPicker = false
    @State private var selectedExhibit: ARExhibit? = ARExhibit.samples.first
    
    var body: some View {
        ZStack {
            // AR视图
            ARViewContainer(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            // 顶部工具栏
            VStack {
                HStack {
                    // 展品选择按钮
                    Button(action: {
                        showExhibitPicker = true
                    }) {
                        HStack {
                            Image(systemName: "cube.box")
                            Text(selectedExhibit?.name ?? "选择展品")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    // 重置按钮
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
                }
                .padding()
                
                if viewModel.isLoading {
                    Text("正在加载模型...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                } else {
                    Text("点击平面放置展品")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                }
                
                Spacer()
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
        .sheet(isPresented: $showExhibitPicker) {
            ExhibitPickerView(selectedExhibit: $selectedExhibit)
        }
        .onChange(of: selectedExhibit) { newExhibit in
            if let exhibit = newExhibit {
                viewModel.loadModel(exhibit: exhibit)
            }
        }
    }
}

// 展品选择器视图
struct ExhibitPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedExhibit: ARExhibit?
    
    var body: some View {
        NavigationView {
            List(ARExhibit.samples) { exhibit in
                Button(action: {
                    selectedExhibit = exhibit
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exhibit.name)
                                .font(.headline)
                            Text(exhibit.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if selectedExhibit?.id == exhibit.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("选择展品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
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