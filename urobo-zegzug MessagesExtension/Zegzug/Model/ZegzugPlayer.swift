import SwiftUI

class ZegzugPlayer {
    let num: PlayerNumber

    var orangeNeighbours: [[Int]] = .init()
    var greenNeighbours: [[[Int]]] = .init()

    var placedPebbles: Int = 0

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
}

extension ZegzugPlayer {
    enum PlayerNumber {
        case first
        case second
    }
}
