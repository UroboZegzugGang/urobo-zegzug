import Foundation

enum UroboPlayer: String {
    static func fromString(_ string: String) -> UroboPlayer? {
        UroboPlayer(rawValue: string)
    }

    var opposite: UroboPlayer { self == .dark ? .light : .dark }

    case light = "light"
    case dark = "dark"
}
