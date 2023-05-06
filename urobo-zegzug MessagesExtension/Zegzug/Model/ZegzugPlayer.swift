enum ZegzugPlayer {
    case first
    case second

    var circleState: CircleState {
        switch self {
        case .first:
            return .playerOne
        case .second:
            return .playerTwo
        }
    }
}
