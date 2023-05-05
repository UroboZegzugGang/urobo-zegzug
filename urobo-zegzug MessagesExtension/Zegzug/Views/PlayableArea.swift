import SwiftUI

struct PlayableArea: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        GeometryReader { geo in
            let normalizedCenters = viewModel.normalizeCoords(for: geo)

            greenLines(from: normalizedCenters, in: geo)
            orangeLines(from: normalizedCenters, in: geo)
            tappableCircles(from: normalizedCenters, in: geo)
        }
    }

    @ViewBuilder private func greenLines(from coords: [CGPoint], in geo: GeometryProxy) -> some View {
        Path { path in
            path.createClosedPath(start: coords[Constants.greenStartIndex]) { path in
                var currPos = path.currentPoint!
                for nIndex in stride(from: 0, to: viewModel.greenNeighbours.count, by: Constants.stepSize) {
                    let index = viewModel.greenNeighbours[nIndex]
                    path.move(to: coords[index])
                    //Draw short straight lines
                    path.connectLinesByIndexes(start: nIndex,
                                               end: nIndex + Constants.stepSize,
                                               points: coords,
                                               indexes: viewModel.greenNeighbours)
                    //Draw curved lines
                    path.move(to: currPos)
                    path.addCurve(from: currPos, to: coords[index], geometry: geo)
                    currPos = coords[index]
                }
            }
        }
        .stroke(lineWidth: Constants.lineWidth).foregroundColor(.greenLine)
    }

    @ViewBuilder private func orangeLines(from coords: [CGPoint], in geo: GeometryProxy) -> some View {
        Path { path in
            path.createClosedPath(start: coords[Constants.orangeStartIndex]) { path in
                path.connectLinesByIndexes(start: 0,
                                           end: viewModel.orangeNeighbours.count,
                                           points: coords,
                                           indexes: viewModel.orangeNeighbours)
            }
        }
        .stroke(lineWidth: Constants.lineWidth).foregroundColor(.orangeLine)
    }

    @ViewBuilder private func tappableCircles(from coords: [CGPoint], in geo: GeometryProxy) -> some View {
        ForEach(coords.indices, id: \.self) { index in
            Circle(center: coords[index], diameter: viewModel.circleDiameter(in: geo))
                .fill(viewModel.isTapped[index] ? Color.blue : Color.white,
                      stroke: StrokeStyle(lineWidth: Constants.outlineWidth)
                )
                .onTapGesture {
                    viewModel.isTapped[index].toggle()
                }
        }
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
