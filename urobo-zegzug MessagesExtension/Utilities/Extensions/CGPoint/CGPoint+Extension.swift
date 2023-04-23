import Foundation

extension CGPoint {
    func rotate(by angle: CGFloat, around origin: CGPoint) -> CGPoint {
        let dx = self.x - origin.x
        let dy = self.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + angle * CGFloat(Double.pi / 180.0)
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }

    static func -(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
}
