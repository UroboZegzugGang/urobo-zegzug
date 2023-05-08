import Foundation
import Messages

struct UroboState {
    var playerScore: Int?
    var opponentScore: Int?
    var takenCards: TakenCards?
    var calledCard: Int?
    var currentPlayer: UroboPlayer?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let playerScore, let opponentScore, let takenCards, let currentPlayer {
            items.append(URLQueryItem(name: URLQueryKeys.currentPlayerScore, value: String(playerScore)))
            items.append(URLQueryItem(name: URLQueryKeys.otherPlayerScore, value: String(opponentScore)))
            items.append(URLQueryItem(name: URLQueryKeys.takenCards, value: takenCards.value.description))
            items.append(URLQueryItem(name: URLQueryKeys.calledCard, value: String(calledCard ?? -1)))
            items.append(URLQueryItem(name: URLQueryKeys.currentPlayer, value: currentPlayer.rawValue))
        }
        return items
    }

    init() {
        playerScore = .zero
        opponentScore = .zero
        takenCards = TakenCards(value: [])
        calledCard = nil
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
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            switch queryItem.name {
            case URLQueryKeys.currentPlayerScore:
                self.playerScore = Int(value)
            case URLQueryKeys.otherPlayerScore:
                self.opponentScore = Int(value)
            case URLQueryKeys.takenCards:
                self.takenCards = TakenCards.fromCommaSeparatedString(value)
            case URLQueryKeys.calledCard:
                self.playerScore = Int(value)
            case URLQueryKeys.currentPlayer:
                self.playerScore = Int(value)
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

        func toCommaSeparatedString() -> String {
            value.map { String($0) }.joined(separator: ",")
        }

        func contains(_ number: Int) -> Bool {
            value.contains(number)
        }

        mutating func add(_ number: Int) {
            value.insert(number)
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
