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

            // MARK: Draw green lines
            Path { path in
                let startPoint = normalizedCenters[24]
                path.move(to: startPoint)
                var currPos = startPoint
                for nIndex in stride(from: 0, to: viewModel.greenNeighbours.count, by: 3) {
                    let index = viewModel.greenNeighbours[nIndex]
                    path.move(to: normalizedCenters[index])
                    //Draw short straight lines
                    for i in nIndex ..< nIndex + 3 {
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
            .stroke(lineWidth: 5).foregroundColor(.green)

            //MARK: Draw orange lines
            Path { path in
                path.move(to: normalizedCenters[0])
                for nIndex in viewModel.neighbours {
                    path.addLine(to: normalizedCenters[nIndex])
                }
            }
            .stroke(lineWidth: 5).foregroundColor(.orange)

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
