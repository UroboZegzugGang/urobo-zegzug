import Foundation

enum UroboPlayer: String {
    static func fromString(_ string: String) -> UroboPlayer? {
        UroboPlayer(rawValue: string)
    }

    case light = "light"
    case dark = "dark"
}
