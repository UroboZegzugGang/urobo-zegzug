import SwiftUI

struct PlayableArea: View {
    @StateObject var viewModel = ZegzugGameViewModel()

    var body: some View {
        GeometryReader { geo in
            let diameter = geo.size.width / 14
            let normalizedCenters = viewModel.circleCenters.enumerated()
                .map { (index,center) in
                    CGPoint(x: center.x * geo.size.width + diameter/2, y: center.y * geo.size.height).rotate(by: CGFloat(30 * index), around: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                }
            // MARK: Draw green lines between the small circles
            Path { path in
                path.move(to: normalizedCenters[0])
                normalizedCenters.enumerated().forEach { (index, center) in
                    if normalizedCenters.count > index + 12 {
                        path.addLine(to: normalizedCenters[index+12])
                        path.move(to: normalizedCenters[index+1])
                    }
                }
            }
            .stroke(lineWidth: Constants.lineWidth).foregroundColor(.green)

            // MARK: Draw green lines inside the smaller circle
            Path { path in
                // Horizontal lines
                path.addCurve(from: normalizedCenters[25], to: normalizedCenters[24], geometry: geo)

                path.addCurve(from: normalizedCenters[26], to: normalizedCenters[35], geometry: geo)

                path.addCurve(from: normalizedCenters[27], to: normalizedCenters[34], geometry: geo)

                path.addLine(from: normalizedCenters[27], to: normalizedCenters[33])

                path.addCurve(from: normalizedCenters[28], to: normalizedCenters[33], geometry: geo)

                path.addCurve(from: normalizedCenters[29], to: normalizedCenters[32], geometry: geo)

                path.addCurve(from: normalizedCenters[30], to: normalizedCenters[31], geometry: geo)

                // Vertical lines
                path.addCurve(from: normalizedCenters[26], to: normalizedCenters[28], geometry: geo)

                path.addCurve(from: normalizedCenters[25], to: normalizedCenters[29], geometry: geo)

                path.addLine(from: normalizedCenters[24], to: normalizedCenters[30])

                path.addCurve(from: normalizedCenters[35], to: normalizedCenters[31], geometry: geo)

                path.addCurve(from: normalizedCenters[34], to: normalizedCenters[32], geometry: geo)
            }
            .stroke(lineWidth: Constants.lineWidth).foregroundColor(.green)

            //MARK: Orange lines in the middle part
            Path { path in
                drawSection { i, j in
                    path.addLine(from: normalizedCenters[3 + j * 12 + 3 * i],
                                 to: normalizedCenters[4 + j * 12 + 3 * i])
                }
                drawSection { i, j in
                    path.addLine(from: normalizedCenters[j * 12 + i * 4],
                                 to: normalizedCenters[(j + 2) % 3 * 12 + 1 + i * 4])
                }
                drawSection { i, j in
                    path.addLine(from: normalizedCenters[1 + j * 12 + i * 7],
                                 to: normalizedCenters[18*j*j - j*30 + 14 + i * 7])
                }
                drawSection { i, j in
                    path.addLine(from: normalizedCenters[2 + j * 12 + i * 8],
                                 to: normalizedCenters[30*j + 15 - 18*j*j + i * 8])
                }
                drawSection { i, j in
                    path.addLine(from: normalizedCenters[j * 12 + 5 + i * 4],
                                 to: normalizedCenters[-12*j + 30 + i * 4])
                }
                drawSection { i, j in
                    path.addLine(from: normalizedCenters[j * 12 + 7 + i * 4],
                                 to: normalizedCenters[edge: (-18*j*j + 42*j + 8 + i * 4)])
                }
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

    private func drawSection(repeating: (Int, Int) -> Void) {
        for i in 0 ..< 2 {
            for j in 0 ..< 3 {
                repeating(i, j)
            }
        }
    }

    private func circleDiameter(in geo: GeometryProxy) -> CGFloat {
        geo.size.width / 14
    }
}

extension PlayableArea {
    private enum Constants {
        static let lineWidth: CGFloat = 5
        static let outlineWidth: CGFloat = 2
    }
}
