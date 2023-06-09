import SwiftUI

extension Path {
    mutating func addCurve(from point1: CGPoint, to point2: CGPoint, geometry geo: GeometryProxy) {
        func getMiddlePoint(of firstPoint: CGPoint, and secondPoint: CGPoint) -> CGPoint {
            CGPoint(x: (firstPoint.x + secondPoint.x)/2, y: (firstPoint.y + secondPoint.y)/2)
        }

        let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)

        let mid = getMiddlePoint(of: point1, and: point2)
        let control = getMiddlePoint(of: mid, and: center)

        self.move(to: point1)
        self.addQuadCurve(to: point2, control: control)
    }

    mutating func createClosedPath(start: CGPoint, pathLogic: (inout Path) -> Void) {
        self.move(to: start)
        pathLogic(&self)
        self.addLine(to: start)
    }

    mutating func connectLinesByIndexes(start: Int, end: Int, points: [CGPoint], indexes: [Int]) {
        for i in start ..< end {
            let lineIndex = indexes[i]
            self.addLine(to: points[lineIndex])
        }
    }
}
