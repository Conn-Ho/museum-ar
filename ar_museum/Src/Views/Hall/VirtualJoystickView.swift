import SwiftUI

struct VirtualJoystickView: View {
    @State private var stickPosition = CGPoint.zero
    let onDirectionChanged: (CGPoint) -> Void
    
    var body: some View {
        ZStack {
            // 底座
            Circle()
                .fill(Color.gray.opacity(0.3))
            
            // 摇杆
            Circle()
                .fill(Color.gray)
                .frame(width: 50, height: 50)
                .offset(x: stickPosition.x, y: stickPosition.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let radius: CGFloat = 35
                            var position = CGPoint(
                                x: value.location.x - radius,
                                y: value.location.y - radius
                            )
                            
                            let distance = sqrt(position.x * position.x + position.y * position.y)
                            if distance > radius {
                                position = CGPoint(
                                    x: position.x * radius / distance,
                                    y: position.y * radius / distance
                                )
                            }
                            
                            stickPosition = position
                            onDirectionChanged(CGPoint(
                                x: position.x / radius,
                                y: position.y / radius
                            ))
                        }
                        .onEnded { _ in
                            stickPosition = .zero
                            onDirectionChanged(.zero)
                        }
                )
        }
        .frame(width: 120, height: 120)
    }
}