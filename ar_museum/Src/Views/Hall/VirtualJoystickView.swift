import SwiftUI

struct VirtualJoystickView: View {
    @State private var stickPosition = CGPoint.zero
    let onDirectionChanged: (CGPoint) -> Void
    
    var body: some View {
        ZStack {
            // 底座 - 增加大小
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 180, height: 180)  // 增加底座大小
            
            // 摇杆 - 增加大小
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 80, height: 80)    // 增加摇杆大小
                .offset(x: stickPosition.x, y: stickPosition.y)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let radius: CGFloat = 50  // 增加移动范围
                            
                            // 计算相对于中心的位置
                            var position = CGPoint(
                                x: value.location.x - 90, // 相对于中心的x坐标
                                y: value.location.y - 90  // 相对于中心的y坐标
                            )
                            
                            // 限制摇杆移动范围
                            let distance = sqrt(position.x * position.x + position.y * position.y)
                            if distance > radius {
                                position = CGPoint(
                                    x: position.x * radius / distance,
                                    y: position.y * radius / distance
                                )
                            }
                            
                            // 更新摇杆位置
                            stickPosition = position
                            
                            // 发送归一化的方向值
                            let normalizedX = position.x / radius
                            let normalizedY = position.y / radius
                            onDirectionChanged(CGPoint(x: normalizedX, y: normalizedY))
                            
                            // 打印调试信息
                            print("Stick position: \(position), Normalized: (\(normalizedX), \(normalizedY))")
                        }
                        .onEnded { _ in
                            // 释放时重置摇杆位置
                            stickPosition = .zero
                            onDirectionChanged(.zero)
                            print("Joystick released")
                        }
                )
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(60)
    }
}