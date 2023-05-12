import Foundation
import Messages

struct ZegzugState {
    // MARK: Player information

    var playerOne: ZegzugPlayer?
    var playerTwo: ZegzugPlayer?
    var sender: ZegzugPlayer?

    // MARK: Game information

    var circles: [ZegzugCircle]?
    var numOfPebbles: Int
    var rotationValue: Int

    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        if let playerOne, let playerTwo, let circles {
            items.append(URLQueryItem(name: URLQueryKeys.playerOne, value: playerOne.toQueryValue()))
            items.append(URLQueryItem(name: URLQueryKeys.playerTwo, value: playerTwo.toQueryValue()))
            if let sender {
                items.append(URLQueryItem(name: URLQueryKeys.sender, value: sender.toQueryValue()))
            }

            items.append(URLQueryItem(name: URLQueryKeys.circles, value: circles.toString()))
            items.append(URLQueryItem(name: URLQueryKeys.numOfPebbles, value: String(numOfPebbles)))
            items.append(URLQueryItem(name: URLQueryKeys.rotationValue, value: String(rotationValue)))


        }
        return items
    }

    init() {
        self.playerOne = ZegzugPlayer(num: .first)
        self.playerTwo = ZegzugPlayer(num: .second)
        self.sender = nil
        self.circles = nil
        self.numOfPebbles = DefaultValues.numOfPebbles
        self.rotationValue = DefaultValues.rotationValue
    }

    init(playerOne: ZegzugPlayer,
         playerTwo: ZegzugPlayer,
         sender: ZegzugPlayer,
         circles: [ZegzugCircle],
         numOfPebbles: Int,
         rotationValue: Int
    ) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.sender = sender
        self.circles = circles
        self.numOfPebbles = numOfPebbles
        self.rotationValue = rotationValue
    }

    init?(queryItems: [URLQueryItem]) {
        numOfPebbles = DefaultValues.numOfPebbles
        rotationValue = DefaultValues.rotationValue

        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            switch queryItem.name {
            case URLQueryKeys.playerOne:
                playerOne = ZegzugPlayer.from(queryValue: value)
            case URLQueryKeys.playerTwo:
                playerTwo = ZegzugPlayer.from(queryValue: value)
            case URLQueryKeys.sender:
                sender = ZegzugPlayer.from(queryValue: value)
            case URLQueryKeys.circles:
                circles = value.toArray()
            case URLQueryKeys.numOfPebbles:
                numOfPebbles = Int(value) ?? DefaultValues.numOfPebbles
            case URLQueryKeys.rotationValue:
                rotationValue = Int(value) ?? DefaultValues.rotationValue
            default:
                break
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

extension ZegzugState {
    private enum URLQueryKeys {
        static let playerOne = "first"
        static let playerTwo = "second"
        static let sender = "sender"
        static let circles = "circles"
        static let numOfPebbles = "numOfPebbles"
        static let rotationValue = "rotationValue"
    }

    private enum DefaultValues {
        static let numOfPebbles: Int = 6
        static let rotationValue: Int = 0
    }
}
