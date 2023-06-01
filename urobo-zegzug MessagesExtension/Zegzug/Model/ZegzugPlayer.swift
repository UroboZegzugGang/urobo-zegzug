import SwiftUI

class ZegzugPlayer: Codable {
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
            return .black
        case .second:
            return .gray
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

    func copy() -> ZegzugPlayer {
        let player = ZegzugPlayer(num: self.num)
        player.orangeNeighbours = orangeNeighbours
        player.greenNeighbours = greenNeighbours
        player.placedPebbles = placedPebbles
        player.areAllPebblesPlaced = areAllPebblesPlaced

        return player
    }
}

extension ZegzugPlayer: Equatable {
    static func == (lhs: ZegzugPlayer, rhs: ZegzugPlayer) -> Bool {
        lhs.num == rhs.num
    }
}


extension ZegzugPlayer {
    enum PlayerNumber: String, Codable {
        case first = "first"
        case second = "second"
    }
}

extension ZegzugPlayer {
    var queryKey: String {
        num.rawValue
    }

    func toQueryValue() -> String {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonString = String(data: data, encoding: .utf8)
            return jsonString ?? ""
        } catch {
            print("Error converting ZegzugPlayer to string: \(error)")
            return ""
        }
    }

    static func from(queryValue: String) -> ZegzugPlayer? {
        let data = Data(queryValue.utf8)
        do {
            let player = try JSONDecoder().decode(ZegzugPlayer.self, from: data)
            return player
        } catch {
            print("Error converting string to ZegzugPlayer: \(error)")
            return nil
        }
    }
}
