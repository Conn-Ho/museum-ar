import SwiftUI

struct MuseumMapView: View {
    @Binding var isPresented: Bool
    @Binding var currentLocation: String
    
    let floors = ["1楼", "2楼", "3楼"]
    @State private var selectedFloor = "1楼"
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                // 标题栏
                HStack {
                    Text("博物馆地图")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                // 楼层选择
                Picker("楼层", selection: $selectedFloor) {
                    ForEach(floors, id: \.self) { floor in
                        Text(floor).tag(floor)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // 地图内容
                ZStack {
                    // 地图背景
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                    
                    // 地图内容 - 这里应该根据选择的楼层显示不同的地图
                    if selectedFloor == "1楼" {
                        FirstFloorMapView(currentLocation: currentLocation)
                    } else if selectedFloor == "2楼" {
                        SecondFloorMapView(currentLocation: currentLocation)
                    } else {
                        ThirdFloorMapView(currentLocation: currentLocation)
                    }
                }
                .padding()
                
                // 图例
                HStack {
                    LegendItem(color: .blue, label: "当前位置")
                    LegendItem(color: .green, label: "展厅")
                    LegendItem(color: .orange, label: "服务设施")
                    LegendItem(color: .red, label: "紧急出口")
                }
                .padding()
            }
            .background(Color.gray.opacity(0.9))
            .cornerRadius(20)
            .padding()
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct FirstFloorMapView: View {
    let currentLocation: String
    
    var body: some View {
        ZStack {
            // 这里应该是实际的地图图像
            Image("museum_map_floor1")
                .resizable()
                .scaledToFit()
            
            // 当前位置标记
            if currentLocation == "入口大厅" {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 15, height: 15)
                    .position(x: 150, y: 200)
            }
            
            // 其他位置标记...
        }
    }
}

// 其他楼层地图视图类似...
struct SecondFloorMapView: View {
    let currentLocation: String
    
    var body: some View {
        Text("2楼地图")
    }
}

struct ThirdFloorMapView: View {
    let currentLocation: String
    
    var body: some View {
        Text("3楼地图")
    }
} 