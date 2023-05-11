import SwiftUI

extension Shape {
    public func fill<S:ShapeStyle>(_ fillContent: S, stroke: (Color, StrokeStyle)) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(stroke.0, style: stroke.1)
        }
    }
}
