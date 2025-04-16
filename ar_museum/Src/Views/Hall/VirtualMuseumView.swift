import SceneKit
import SwiftUI
import Combine

struct VirtualMuseumView: View {
    @StateObject private var viewModel = VirtualMuseumViewModel()

    var body: some View {
        ZStack {
            SceneView(
                scene: viewModel.scene,
                pointOfView: viewModel.cameraNode,
                options: [.allowsCameraControl]
            )
            .gesture(
                DragGesture()
                    .onChanged(viewModel.handlePan)
                    .onEnded(viewModel.handlePanEnd)
            )
            .gesture(
                MagnificationGesture()
                    .onChanged(viewModel.handlePinch)
            )
            .gesture(
                RotationGesture()
                    .onChanged(viewModel.handleRotation)
            )
            
            // 虚拟摇杆控制
            VirtualJoystickView(
                onDirectionChanged: viewModel.handleJoystickMovement
            )
            .frame(width: 120, height: 120)
            .position(x: 80, y: UIScreen.main.bounds.height - 100)
            
            // 展厅切换按钮
            Button(action: { viewModel.showGalleryList.toggle() }) {
                Image(systemName: "list.bullet")
                    .font(.title)
                    .padding()
            }
            .position(x: UIScreen.main.bounds.width - 50, y: 50)
        }
        .sheet(isPresented: $viewModel.showExhibitDetail, content: {
            if let exhibit = viewModel.selectedExhibit {
                ExhibitDetailView(exhibit: exhibit)
            }
        })
        .sheet(isPresented: $viewModel.showGalleryList) {
            GalleryListView(galleries: viewModel.galleries) { gallery in
                viewModel.switchGallery(to: gallery)
            }
        }
    }
}