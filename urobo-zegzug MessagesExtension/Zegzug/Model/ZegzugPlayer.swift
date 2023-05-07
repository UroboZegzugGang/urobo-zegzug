import SwiftUI

class ZegzugPlayer {
    let num: PlayerNumber

    var orangeNeighbours: [[Int]] = .init()
    var greenNeighbours: [[[Int]]] = .init()

    var circleState: CircleState {
        switch num {
        case .first:
            return .playerOne
        case .second:
            return .playerTwo
        }
    }

    var lineColor: Color {
        switch num {
        case .first:
            return .blue
        case .second:
            return .yellow
        }
    }

    init(num: PlayerNumber) {
        self.num = num
    }

    func updateNeighbours(with array: [Any], color: NeighbourColor) {
        switch color {
        case .orange:
            guard let array = array as? [[Int]] else { return }
            orangeNeighbours = array
        case .green:
            guard let array = array as? [[[Int]]] else { return }
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
