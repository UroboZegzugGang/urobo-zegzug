import Foundation
import SwiftUI

final class ZegzugGameViewModel: ObservableObject {
    @Published var circles = [ZegzugCircle]()

    @Published var showingHowTo = false

    @Published var orangeNeighbours: [Int] = [
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

    private var currentPlayer: ZegzugPlayer = .first

    @Published var playerOneOrangeNeighbours: [[Int]] = .init()
    @Published var playerOneGreenNeighbours: [[Int]] = .init()
    @Published var playerTwoOrangeNeighbours: [[Int]] = .init()
    @Published var playerTwoGreenNeighbours: [[Int]] = .init()

    init() {
        let startOuterX = 0.0
        let startInnerX = 0.25
        let startMiddleX = (startInnerX + startOuterX) / 2

        let startY = 0.5

        let outer = CGPoint(x: startOuterX, y: startY)
        let middle = CGPoint(x: startMiddleX, y: startY)
        let inner = CGPoint(x: startInnerX, y: startY)

        for _ in 0 ..< 12 {
            circles.append(ZegzugCircle(center: outer, state: .none))
        }

        for _ in 0 ..< 12 {
            circles.append(ZegzugCircle(center: middle, state: .none))
        }

        for _ in 0 ..< 12 {
            circles.append(ZegzugCircle(center: inner, state: .none))
        }

        // TODO: rotate by the stored value in the gameState
        rotateBoardBy(sections: 0)
    }

    func normalizeCoords(for geo: GeometryProxy) -> [CGPoint] {
        let rotationDegree: CGFloat = 30
        return circles
            .enumerated()
            .map { index, circle in
                normalizeCoords(circle.center, in: geo).rotate(by: rotationDegree * CGFloat(index),
                                                        around: middle(of: geo))
            }
    }

    func circleDiameter(in geo: GeometryProxy) -> CGFloat {
        geo.size.width / 14
    }

    func handleTap(index: Int) {
        guard circles[index].state == .none || circles[index].state == currentPlayer.circleState
        else { return }
        if circles[index].state == .none {
            circles[index].state = currentPlayer.circleState
        } else {
            circles[index].state = .none
        }
        //currentPlayer = currentPlayer == .first ? .second : .first

        determineAllNeighbours()
    }

    private func determineAllNeighbours() {
        determineNeighbours(for: .first, color: .green)
        determineNeighbours(for: .first, color: .orange)
    }

    private func determineNeighbours(for player: ZegzugPlayer, color: NeighbourColor) {
        let firstPersonCLicked = circles.filter { $0.state == player.circleState }
        guard firstPersonCLicked.count > 1 else { return }
        var neighbourList = [[Int]]()
        switch player {
        case .first:
            neighbourList = color == .orange ? playerOneOrangeNeighbours : playerOneGreenNeighbours
        case .second:
            neighbourList = color == .orange ? playerTwoOrangeNeighbours : playerTwoGreenNeighbours
        }
        neighbourList.removeAll()

        for index in circles.indices {
            guard circles[index].state == player.circleState else { continue }
            var noNeighbours = true
            for outerIndex in neighbourList.indices {
                guard neighbourList.indices.contains(outerIndex) else { break }
                for innerIndex in neighbourList[outerIndex].indices {
                    guard neighbourList.indices.contains(outerIndex) else { break }
                    guard neighbourList[outerIndex].indices.contains(innerIndex) else { break }
                    guard !neighbourList[outerIndex].contains(index) else { break }
                    let comparable = neighbourList[outerIndex][innerIndex]
                    let status = getNeighbourStatus(for: color, first: index, second: comparable)
                    switch status {
                    case .after:
                        neighbourList[outerIndex].append(index)
                        noNeighbours = false
                    case .before:
                        neighbourList[outerIndex].insert(index, at: innerIndex)
                        noNeighbours = false
                    case .none:
                        break
                    }
                    neighbourList = mergeConnectedLines(for: color, player: player, in: neighbourList)
                }
            }
            if noNeighbours {
                neighbourList.append([index])
                neighbourList = mergeConnectedLines(for: color, player: player, in: neighbourList)
            }
        }

        //if merged.count > 0, merged.first!.count > 0 {
//        neighbourList = mergeConnectedLines(for: color, player: player, in: neighbourList)
        switch player {
        case .first:
            switch color {
            case .orange:
                playerOneOrangeNeighbours = neighbourList
            case .green:
                playerOneGreenNeighbours = neighbourList
            }
        case .second:
            switch color {
            case .orange:
                playerTwoOrangeNeighbours = neighbourList
            case .green:
                playerTwoGreenNeighbours = neighbourList
            }
        }
    }

    private func mergeConnectedLines(for color: NeighbourColor, player: ZegzugPlayer, in neighbourList: [[Int]]) -> [[Int]] {
        var merged = [[Int]]()
        var current = [Int]()

        for subarray in neighbourList {
            if current.isEmpty {
                current = subarray
            } else {
                if current.last == subarray.first {
                    current.append(contentsOf: subarray.dropFirst())
                } else if current.first == subarray.last {
                    current.insert(contentsOf: subarray.dropLast(), at: 0)
                } else {
                    merged.append(current)
                    current = subarray
                }
            }
        }

        merged.append(current)
        return merged
    }

    func getColorFor(index: Int) -> Color {
        switch circles[index].state {
        case .none:
            return .white
        case .playerOne:
            return .blue
        case .playerTwo:
            return .mint
        }
    }

    private enum NeighbourStatus {
        case before
        case after
        case none
    }

    private func getNeighbourStatus(for color: NeighbourColor, first: Int, second: Int) -> NeighbourStatus {
        var neighbourList = [Int]()
        switch color {
        case .orange:
            neighbourList = orangeNeighbours
        case .green:
            neighbourList = greenNeighbours
        }
        let index = neighbourList.firstIndex(of: first)!
        if color == .orange {
            if neighbourList[(index + 1) % 36] == second {
                return .before
            }
            if neighbourList[index - 1 < 0 ? 35 : index - 1] == second {
                return .after
            }
        }
        if color == .green {
            switch index % 3 {
            case 0:
            if neighbourList[(index + 3) % 36] == second || neighbourList[(index + 1) % 36] == second {
                    return .before
                }
                if neighbourList[index - 3 + (index - 3 < 0 ? 36 : 0)] == second {
                    return .after
                }
            case 1:
                if neighbourList[(index + 1) % 36] == second {
                    return .before
                }
                if neighbourList[index - 1 < 0 ? 35 : index - 1] == second {
                    return .after
                }
            case 2:
                if neighbourList[index - 1 < 0 ? 35 : index - 1] == second{
                    return .after
                }
            default:
                break
            }
        }
        return .none
    }

    private func middle(of geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
    }

    private func normalizeCoords(_ center: CGPoint, in geo: GeometryProxy) -> CGPoint {
        CGPoint(x: center.x * geo.size.width + circleDiameter(in: geo) / 2, y: center.y * geo.size.height)
    }

    private func rotateBoardBy(sections: Int) {
        orangeNeighbours = orangeNeighbours.map { nIndex in
            offsetIndex(nIndex, by: sections)
        }
    }

    private func offsetIndex(_ index: Int, by offset: Int) -> Int {
        let newIndex = (index + offset)
        if index < 12 {
            return newIndex % 12
        }
        if index < 24 {
            return newIndex >= 24 ? newIndex % 24 + 12 : newIndex % 24
        }
        return newIndex >= 36 ? newIndex % 36 + 24 : newIndex % 36
    }
}
