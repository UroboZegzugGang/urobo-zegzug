import SwiftUI

extension Shape {
    public func fill<S:ShapeStyle>(_ fillContent: S, stroke: (color: Color, style: StrokeStyle)) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(stroke.color, style: stroke.style)
        }
    }
}
