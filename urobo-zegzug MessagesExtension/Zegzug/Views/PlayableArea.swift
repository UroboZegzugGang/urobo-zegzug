import SwiftUI

struct PlayableArea: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        GeometryReader { geo in
            let _ = viewModel.normalizeCoords(for: geo)

            greenLines(in: geo)
            orangeLines(in: geo)
            neighbourLines(for: viewModel.playerOne, in: geo)
            tappableCircles(in: geo)
        }
    }

    @ViewBuilder private func greenLines(in geo: GeometryProxy) -> some View {
        Path { path in
            path.createClosedPath(start: viewModel.circles[Constants.greenStartIndex].center) { path in
                var currPos = path.currentPoint!
                for nIndex in stride(from: 0, to: viewModel.greenNeighbours.count, by: Constants.stepSize) {
                    let index = viewModel.greenNeighbours[nIndex]
                    path.move(to: viewModel.circles[index].center)
                    //Draw short straight lines
                    path.connectLinesByIndexes(start: nIndex,
                                               end: nIndex + Constants.stepSize,
                                               points: viewModel.circles.map { $0.center },
                                               indexes: viewModel.greenNeighbours)
                    //Draw curved lines
                    path.move(to: currPos)
                    path.addCurve(from: currPos, to: viewModel.circles[index].center, geometry: geo)
                    currPos = viewModel.circles[index].center
                }
            }
        }
        .stroke(lineWidth: Constants.lineWidth).foregroundColor(.greenLine)
    }

    @ViewBuilder private func orangeLines(in geo: GeometryProxy) -> some View {
        Path { path in
            path.createClosedPath(start: viewModel.circles[Constants.orangeStartIndex].center) { path in
                path.connectLinesByIndexes(start: 0,
                                           end: viewModel.orangeNeighbours.count,
                                           points: viewModel.circles.map { $0.center },
                                           indexes: viewModel.orangeNeighbours)
            }
        }
        .stroke(lineWidth: Constants.lineWidth).foregroundColor(.orangeLine)
    }

    @ViewBuilder private func neighbourLines(for player: ZegzugPlayer, in geo: GeometryProxy) -> some View {
        Path { path in
            for neighbours in player.list(for: .orange) {
                path.move(to: viewModel.circles[neighbours.first!].center)
                for circle in neighbours {
                    path.addLine(to: viewModel.circles[circle].center)
                }
            }
        }
        .stroke(player.lineColor, style: StrokeStyle(lineWidth: Constants.neighbourLineWidth, dash: Constants.neighbourLineDash))

        Path { path in
            guard player.list(for: .orange).count > 0,
                  player.list(for: .green).first!.count > 0
            else { return }

            // straigth lines
            for list in player.list(for: .green) {
                var currIndex = list.first!
                for index in list {
                    path.move(to: viewModel.circles[currIndex].center)
                    let pos = viewModel.greenNeighbours.firstIndex(of: index)!
                    if pos % 3 != 0 {
                        path.addLine(to: viewModel.circles[index].center)
                    }
                    currIndex = index
                }
            }

            // curved lines
            for list in player.list(for: .green) {
                for index in list {
                    for iterIndex in list {
                        guard index != iterIndex else { continue }
                        let currPos = viewModel.greenNeighbours.firstIndex(of: index)!
                        let pos = viewModel.greenNeighbours.firstIndex(of: iterIndex)!
                        if pos % 3 == 0, currPos % 3 == 0 {
                            guard (currPos + 3) % 36 == pos || currPos - 3 + (currPos - 3 < 0 ? 36 : 0) == pos else { continue }
                            path.addCurve(from: viewModel.circles[index].center, to: viewModel.circles[iterIndex].center, geometry: geo)
                        }
                    }
                }
            }
        }
        .stroke(player.lineColor, style: StrokeStyle(lineWidth: Constants.neighbourLineWidth, dash: Constants.neighbourLineDash))
    }

    @ViewBuilder private func tappableCircles(in geo: GeometryProxy) -> some View {
        ForEach(Array(viewModel.circles.enumerated()), id: \.element.id) { index, circle in
            Circle(center: circle.center, diameter: viewModel.circleDiameter(in: geo))
                .fill(circle.fillColor,
                      stroke: StrokeStyle(lineWidth: Constants.outlineWidth)
                )
                .onTapGesture {
                    viewModel.tapped(circle)
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
        static let neighbourLineWidth: CGFloat = 2
        static let neighbourLineDash: [CGFloat] = [3]
    }
}
