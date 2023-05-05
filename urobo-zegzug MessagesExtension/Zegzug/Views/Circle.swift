import SwiftUI

struct Circle: Shape {
    let center: CGPoint
    let diameter: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = diameter / 2
        let size = CGSize(width: diameter, height: diameter)

        path.addEllipse(in: CGRect(origin: CGPoint(x: center.x - radius, y: center.y - radius), size: size))

        return path
    }
}
