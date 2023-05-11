enum TurnState {
    case place
    case select
    case move
    case won
    case lost

    var title: String {
        switch self {
        case .place:
            return "Place a pebble"
        case .select:
            return "Select a pebble to move"
        case .move:
            return "Choose a neighbouring place"
        case .won:
            return "You have won!"
        case .lost:
            return "You have lost."
        }
    }
}
