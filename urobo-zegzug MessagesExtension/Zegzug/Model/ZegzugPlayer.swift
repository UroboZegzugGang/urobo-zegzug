import SwiftUI

class ZegzugPlayer {
    let num: PlayerNumber

    var orangeNeighbours: [[Int]] = .init()
    var greenNeighbours: [[[Int]]] = .init()

    var placedPebbles: Int = 0
    var areAllPebblesPlaced: Bool = false

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

    func placePebble(max: Int) {
        guard placedPebbles < max else { return }
        placedPebbles += 1
        areAllPebblesPlaced = placedPebbles == max
    }
}

extension ZegzugPlayer {
    enum PlayerNumber {
        case first
        case second
    }
}
