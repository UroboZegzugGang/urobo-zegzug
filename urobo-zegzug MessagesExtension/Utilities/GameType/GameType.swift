import Foundation

enum GameType {
    case urobo, zegzug

    var name: String {
        switch self {
        case .urobo: return "Urobo"
        case .zegzug: return "ZegZug"
        }
    }
}
