import Foundation

enum GameType: String {
    case urobo = "Urobo"
    case zegzug = "ZegZug"

    var name: String {
        switch self {
        case .urobo: return "Urobo"
        case .zegzug: return "ZegZug"
        }
    }
}
