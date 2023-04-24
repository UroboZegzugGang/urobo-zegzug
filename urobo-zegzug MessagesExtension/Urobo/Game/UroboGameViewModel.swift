import Foundation

final class UroboGameViewModel: ObservableObject {
    @Published private(set) var playerCurrentScore: Int = 0
    @Published private(set) var opponentCurrentScore: Int = 0
    @Published private(set) var takenCards: Set<Int> = []

    @Published var helpShowing: Bool = false
    @Published var selectedCardNumber: Int?

    init() {}

    func cardTapped(_ cardNumber: Int) {
        if selectedCardNumber == cardNumber {
            selectedCardNumber = nil
        } else {
            selectedCardNumber = cardNumber
        }
    }
}
