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
            return .black
        case .playerTwo:
            return .gray
        case .wrong:
            return .red
        }
    }
}
