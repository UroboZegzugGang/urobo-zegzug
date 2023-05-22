import Foundation
import Messages

struct UroboState {
    var playerScore: Int
    var opponentScore: Int
    var takenCards: TakenCards
    var calledCard: Int
    var currentPlayer: UroboPlayer

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: URLQueryKeys.currentPlayerScore, value: String(playerScore)),
            URLQueryItem(name: URLQueryKeys.otherPlayerScore, value: String(opponentScore)),
            URLQueryItem(name: URLQueryKeys.takenCards, value: takenCards.toCommaSeparatedString()),
            URLQueryItem(name: URLQueryKeys.calledCard, value: String(calledCard)),
            URLQueryItem(name: URLQueryKeys.currentPlayer, value: currentPlayer.rawValue)
        ]
        return items
    }

    init() {
        playerScore = .zero
        opponentScore = .zero
        takenCards = TakenCards(value: [])
        calledCard = -1
        currentPlayer = .dark
    }

    init(
        playerScore: Int,
        opponentScore: Int,
        takenCards: TakenCards,
        calledCard: Int,
        currentPlayer: UroboPlayer
    ) {
        self.playerScore = playerScore
        self.opponentScore = opponentScore
        self.takenCards = takenCards
        self.calledCard = calledCard
        self.currentPlayer = currentPlayer
    }

    init?(queryItems: [URLQueryItem]) {
        self.init()
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            switch queryItem.name {
            case URLQueryKeys.currentPlayerScore:
                self.playerScore = Int(value) ?? .zero
            case URLQueryKeys.otherPlayerScore:
                self.opponentScore = Int(value) ?? .zero
            case URLQueryKeys.takenCards:
                self.takenCards = TakenCards.fromCommaSeparatedString(value)
            case URLQueryKeys.calledCard:
                self.calledCard = Int(value) ?? -1
            case URLQueryKeys.currentPlayer:
                self.currentPlayer = UroboPlayer(rawValue: value) ?? .dark
            default: continue
            }
        }
    }

    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }

        self.init(queryItems: queryItems)
    }
}

extension UroboState {
    struct TakenCards {
        static func fromCommaSeparatedString(_ string: String) -> TakenCards {
            let stringArray = string.split(separator: ",")
            let value = Set<Int>(stringArray.compactMap{ Int($0) })
            return TakenCards(value: value)
        }

        var value: Set<Int>

        init(value: Set<Int>) {
            self.value = value
        }

        mutating func addElements(of array: [Int]) {
            value.formUnion(array)
        }

        func toCommaSeparatedString() -> String {
            let str = value.map { String($0) }.joined(separator: ",")
            return str
        }

        func contains(_ number: Int) -> Bool {
            value.contains(number)
        }
    }
}

extension UroboState {
    private enum URLQueryKeys {
        static let currentPlayerScore = "currentplayerscore"
        static let otherPlayerScore = "otherplayerscore"
        static let takenCards = "takencards"
        static let calledCard = "calledcard"
        static let currentPlayer = "currentplayer"
    }
}
