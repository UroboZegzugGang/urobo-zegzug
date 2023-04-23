import Foundation

final class ZegzugGameViewModel: ObservableObject {
    @Published var circleCenters = [CGPoint]()
    @Published var isTapped = [Bool]()

    init() {
        let startOuterX = 0.0
        let startInnerX = 0.25
        let startMiddleX = (startInnerX + startOuterX) / 2

        let startY = 0.5

        let outer = CGPoint(x: startOuterX, y: startY)
        let middle = CGPoint(x: startMiddleX, y: startY)
        let inner = CGPoint(x: startInnerX, y: startY)

        for _ in 0 ..< 12 {
            circleCenters.append(outer)
        }

        for _ in 0 ..< 12 {
            circleCenters.append(middle)
        }

        for _ in 0 ..< 12 {
            circleCenters.append(inner)
        }

        isTapped = .init(repeating: false, count: 36)
    }
}
