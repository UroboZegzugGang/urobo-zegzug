import SwiftUI

struct ZegzugCircle: Identifiable {
    let id = UUID()
    
    var center: CGPoint
    var state: CircleState

    var fillColor: Color {
        switch state {
        case .none:
            return .white
        case .playerOne:
            return .zegzugPlayerOne
        case .playerTwo:
            return .zegzugPlayerTwo
        case .wrong:
            return .red
        }
    }
}
