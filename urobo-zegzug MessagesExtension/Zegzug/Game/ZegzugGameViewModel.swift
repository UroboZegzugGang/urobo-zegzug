import Foundation

final class ZegzugGameViewModel: ObservableObject {
    @Published var circleCenters = [CGPoint]()
    @Published var isTapped = [Bool]()

    let orangeNeighbours: [Int] = [
        0,
        25,
        26,
        3,
        4,
        29,
        6,
        7,
        8,
        21,
        22,
        35,
        12,
        1,
        14,
        27,
        28,
        17,
        18,
        19,
        32,
        33,
        10,
        23,
        24,
        13,
        2,
        15,
        16,
        5,
        30,
        31,
        20,
        9,
        34,
        11,
    ]

    let greenNeighbours: [Int] = [
        24,
        12,
        0,
        25,
        13,
        1,
        29,
        17,
        5,
        32,
        20,
        8,
        34,
        22,
        10,
        27,
        15,
        3,
        33,
        21,
        9,
        28,
        16,
        4,
        26,
        14,
        2,
        35,
        23,
        11,
        31,
        19,
        7,
        30,
        18,
        6,
    ]

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
