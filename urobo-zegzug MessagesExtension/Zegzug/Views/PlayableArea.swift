import SwiftUI

struct PlayableArea: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        GeometryReader { geo in
            let normalizedCenters = viewModel.circleCenters
                .enumerated()
                .map { (index,center) in
                    normalizeCoords(center, in: geo).rotate(by: Constants.rotationDegree * CGFloat(index),
                                                            around: middle(of: geo))
                }

            // MARK: Draw green lines
            Path { path in
                let startPoint = normalizedCenters[Constants.greenStartIndex]
                path.move(to: startPoint)
                var currPos = startPoint
                for nIndex in stride(from: 0, to: viewModel.greenNeighbours.count, by: Constants.stepSize) {
                    let index = viewModel.greenNeighbours[nIndex]
                    path.move(to: normalizedCenters[index])
                    //Draw short straight lines
                    for i in nIndex ..< nIndex + Constants.stepSize {
                        let lineIndex = viewModel.greenNeighbours[i]
                        path.addLine(to: normalizedCenters[lineIndex])
                    }
                    //Draw curved lines
                    path.move(to: currPos)
                    path.addCurve(from: currPos, to: normalizedCenters[index], geometry: geo)
                    currPos = normalizedCenters[index]
                }
                path.addLine(to: startPoint)
            }
            .stroke(lineWidth: Constants.lineWidth).foregroundColor(.green)

            //MARK: Draw orange lines
            Path { path in
                let startPoint = normalizedCenters[Constants.orangeStartIndex]
                path.move(to: startPoint)
                for nIndex in viewModel.orangeNeighbours {
                    path.addLine(to: normalizedCenters[nIndex])
                }
                path.addLine(to: startPoint)
            }
            .stroke(lineWidth: Constants.lineWidth).foregroundColor(.orange)

            // MARK: Draw little circles
            ForEach(normalizedCenters.indices, id: \.self) { index in
                Circle(center: normalizedCenters[index], diameter: circleDiameter(in: geo))
                    .fill(viewModel.isTapped[index] ? Color.blue : Color.white,
                          stroke: StrokeStyle(lineWidth: Constants.outlineWidth)
                    )
                    .onTapGesture {
                        viewModel.isTapped[index].toggle()
                    }
            }
        }
    }

    private func circleDiameter(in geo: GeometryProxy) -> CGFloat {
        geo.size.width / 14
    }

    private func middle(of geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
    }

    private func normalizeCoords(_ center: CGPoint, in geo: GeometryProxy) -> CGPoint {
        CGPoint(x: center.x * geo.size.width + circleDiameter(in: geo) / 2, y: center.y * geo.size.height)
    }
}

extension PlayableArea {
    private enum Constants {
        static let lineWidth: CGFloat = 5
        static let outlineWidth: CGFloat = 2
        static let stepSize: Int = 3
        static let rotationDegree: CGFloat = 30
        static let orangeStartIndex: Int = 0
        static let greenStartIndex: Int = 24
    }
}
