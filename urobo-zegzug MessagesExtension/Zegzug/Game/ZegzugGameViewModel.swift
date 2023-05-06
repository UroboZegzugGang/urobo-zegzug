import SwiftUI

final class ZegzugGameViewModel: ObservableObject {
    @Published var circles = [ZegzugCircle]()
    @Published var showingHowTo = false
    @Published var playerOne: ZegzugPlayer = ZegzugPlayer(num: .first)
    @Published var playerTwo: ZegzugPlayer = ZegzugPlayer(num: .second)

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

    private var currentPlayer: ZegzugPlayer!

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

        currentPlayer = playerOne
    }

    func normalizeCoords(for geo: GeometryProxy) {
        let rotationDegree: CGFloat = 30
        DispatchQueue.main.async { [unowned self] in
            for (index, circle) in circles.enumerated() {
                let newCenter = normalizeCoords(circle.center, in: geo).rotate(by: rotationDegree * CGFloat(index),
                                                                               around: middle(of: geo))
                // This guard is critical since the view could call this function multiple times, resulting in the
                // the coordinates being placed further and further off the screen. This prevents that.
                guard CGRectContainsPoint(geo.frame(in: .local), newCenter) else { continue }
                circles[index].center = newCenter
            }
        }
    }

    func circleDiameter(in geo: GeometryProxy) -> CGFloat {
        geo.size.width / 14
    }

    func tapped(_ circle: ZegzugCircle) {
        guard circle.state == .none || circle.state == currentPlayer.circleState,
              let index = circles.firstIndex(where: { $0.id == circle.id })
        else { return }
        if circle.state == .none {
            circles[index].state = currentPlayer.circleState
        } else {
            circles[index].state = .none
        }

        togglePlayers()
        determineAllNeighbours()
    }

    private func togglePlayers() {
        currentPlayer = currentPlayer.num == .first ? playerTwo : playerOne
    }

    private func determineAllNeighbours() {
        determineNeighbours(for: playerOne, color: .green)
        determineNeighbours(for: playerOne, color: .orange)

        determineNeighbours(for: playerTwo, color: .green)
        determineNeighbours(for: playerTwo, color: .orange)
    }

    private func determineNeighbours(for player: ZegzugPlayer, color: NeighbourColor) {
        let firstPersonCLicked = circles.filter { $0.state == player.circleState }
        guard firstPersonCLicked.count > 1 else { return }

        var neighbourList = player.list(for: color)
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

        player.updateNeighbours(with: neighbourList, color: color)
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

private extension ZegzugGameViewModel {
    enum NeighbourStatus {
        case before
        case after
        case none
    }
}
