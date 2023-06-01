import SwiftUI

struct BackgroundCircles: View {
    @State var height: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            Circle(center: middle(of: geo), diameter: smallCircleDiameter(in: geo))
                .stroke(.black, style: StrokeStyle(lineWidth: Constants.lineWidth))

            Circle(center: middle(of: geo), diameter: bigCircleDiameter(in: geo))
                .stroke(.black, style: StrokeStyle(lineWidth: Constants.lineWidth))
                .onAppear {
                    height = geo.size.width
                }
        }
        .frame(maxHeight: height)
    }

    private func middle(of geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
    }

    private func smallCircleDiameter(in geo: GeometryProxy) -> CGFloat {
        func tinyCircleSize() -> CGFloat {
            geo.size.width / 10.0
        }

        return geo.size.width / 4 + tinyCircleSize()
    }

    private func bigCircleDiameter(in geo: GeometryProxy) -> CGFloat {
        geo.size.width
    }
}

extension BackgroundCircles {
    private enum Constants {
        static let lineWidth: CGFloat = 2
    }
}
