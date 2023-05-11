import SwiftUI

struct PlayableArea: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        GeometryReader { geo in
            let _ = viewModel.normalizeCoords(for: geo)

            greenLines(in: geo)
            orangeLines(in: geo)
            neighbourLines(for: viewModel.playerOne, in: geo)
            neighbourLines(for: viewModel.playerTwo, in: geo)
            tappableCircles(in: geo)
        }
    }

    @ViewBuilder private func greenLines(in geo: GeometryProxy) -> some View {
        Path { path in
            path.createClosedPath(start: viewModel.circles[Constants.greenStartIndex].center) { path in
                guard var currCurvedPos = viewModel.greenNeighbours.first?.first else { return }
                for list in viewModel.greenNeighbours {
                    path.connectLinesByIndexes(points: viewModel.circles.map { $0.center },
                                               indexes: list)

                    guard list.first! != currCurvedPos else { continue }
                    path.addCurve(from: viewModel.circles[currCurvedPos].center,
                                  to: viewModel.circles[list.first!].center,
                                  geometry: geo)
                    currCurvedPos = list.first!
                }
            }
        }
        .stroke(lineWidth: Constants.lineWidth).foregroundColor(.zegzugGreen)
    }

    @ViewBuilder private func orangeLines(in geo: GeometryProxy) -> some View {
        Path { path in
            path.createClosedPath(start: viewModel.circles[Constants.orangeStartIndex].center) { path in
                path.connectLinesByIndexes(points: viewModel.circles.map { $0.center },
                                           indexes: viewModel.orangeNeighbours)
            }
        }
        .stroke(lineWidth: Constants.lineWidth).foregroundColor(.zegzugOrange)
    }

    @ViewBuilder private func neighbourLines(for player: ZegzugPlayer, in geo: GeometryProxy) -> some View {
        Path { path in
            for neighbours in player.orangeNeighbours {
                path.move(to: viewModel.circles[neighbours.first!].center)
                for circle in neighbours {
                    path.addLine(to: viewModel.circles[circle].center)
                }
            }
        }
        .stroke(player.lineColor, style: StrokeStyle(lineWidth: Constants.neighbourLineWidth, dash: Constants.neighbourLineDash))

        Path { path in
            guard player.greenNeighbours.count > 0,
                  player.greenNeighbours.first!.count > 0,
                  player.greenNeighbours.first!.first!.count > 0
            else { return }
            for lines in player.greenNeighbours {
                guard var currCurvePos = lines.first?.first else { continue }
                for straightLines in lines {
                    path.move(to: viewModel.circles[straightLines.first!].center)
                    for circle in straightLines {
                        path.addLine(to: viewModel.circles[circle].center)
                    }

                    if straightLines.first! != currCurvePos {
                        path.addCurve(from: viewModel.circles[currCurvePos].center,
                                      to: viewModel.circles[straightLines.first!].center,
                                      geometry: geo)
                    }
                    currCurvePos = straightLines.first!
                }
            }
        }
        .stroke(player.lineColor, style: StrokeStyle(lineWidth: Constants.neighbourLineWidth, dash: Constants.neighbourLineDash))
    }

    @ViewBuilder private func tappableCircles(in geo: GeometryProxy) -> some View {
        ForEach(Array(viewModel.circles.enumerated()), id: \.element.id) { index, circle in
            Circle(center: circle.center, diameter: viewModel.circleDiameter(in: geo))
                .fill(circle.fillColor,
                      stroke: (viewModel.selectedIndex == index ? .yellow : .black, StrokeStyle(lineWidth: Constants.outlineWidth))
                )
                .onTapGesture {
                    viewModel.tapped(circle)
                }
                .shake(circle.state == .wrong)
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
        static let curvedNeighbourDistance: Int = 3
    }
}
