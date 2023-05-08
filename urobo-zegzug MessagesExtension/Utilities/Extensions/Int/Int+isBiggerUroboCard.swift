import Foundation

extension Int {
    func isBiggerUroboCard(than card: Int) -> Bool? {
        guard self > 0, self <= 12, card > 0, card <= 12 else { return nil }
        var biggerCards: [Int] = []
        for index in 1...6 {
            biggerCards.append( (self+index) % 13 )
        }
        return biggerCards.contains(card)
    }
}
