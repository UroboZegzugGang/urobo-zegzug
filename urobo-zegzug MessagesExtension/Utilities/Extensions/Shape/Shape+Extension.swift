import SwiftUI

extension Shape {
    public func fill<S:ShapeStyle>(_ fillContent: S, stroke: StrokeStyle) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(style:stroke)
        }
    }
}
