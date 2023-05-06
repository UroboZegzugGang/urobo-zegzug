import Foundation

class ZegzugPlayer {
    let num: PlayerNumber

    var orangeNeighbours: [[Int]] = .init()
    var greenNeighbours: [[Int]] = .init()

    var circleState: CircleState {
        switch num {
        case .first:
            return .playerOne
        case .second:
            return .playerTwo
        }
    }

    init(num: PlayerNumber) {
        self.num = num
    }

    func list(for color: NeighbourColor) -> [[Int]] {
        switch color {
        case .orange:
            return orangeNeighbours
        case .green:
            return greenNeighbours
        }
    }

    func updateNeighbours(with array: [[Int]], color: NeighbourColor) {
        switch color {
        case .orange:
            orangeNeighbours = array
        case .green:
            greenNeighbours = array
        }
    }
}

extension ZegzugPlayer {
    enum PlayerNumber {
        case first
        case second
    }
}
