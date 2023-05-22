import Foundation

protocol UroboGameViewModelDelegate {
    func endTurn(with state: UroboState)
    func endGame(with state: UroboState)
}

final class UroboGameViewModel: ObservableObject {
    var delegate: UroboGameViewModelDelegate?

    @Published private(set) var state: UroboState
    @Published var helpShowing: Bool = false
    @Published var selectedCardNumber: Int?

    init(state: UroboState) {
        self.state = state
    }

    func cardTapped(_ number: Int) {
        guard playerOfCard(number) == state.currentPlayer else { return }
        if selectedCardNumber == number {
            selectedCardNumber = nil
        } else {
            selectedCardNumber = number
        }
    }

    func choosePressed() {
        guard selectedCardNumber != nil else { return }
        if state.calledCard == -1 {
            call()
        } else {
            answer()
        }
    }

    func isCardTaken(_ card: Int) -> Bool {
        state.takenCards.contains(card)
    }

    func playerOfCard(_ card: Int) -> UroboPlayer {
        card % 2 == 0 ? .dark : .light
    }

    private func call() {
        guard let selectedCardNumber else { return }
        let newState = UroboState(
            playerScore: state.opponentScore,
            opponentScore: state.playerScore,
            takenCards: state.takenCards,
            calledCard: selectedCardNumber,
            currentPlayer: state.currentPlayer == .dark ? .light : .dark
        )
        delegate?.endTurn(with: newState)
    }

    private func answer() {
        guard let selectedCardNumber else { return }
        state.takenCards.addElements(of: [selectedCardNumber, state.calledCard])

        if let currentPlayerTakes = selectedCardNumber.isBiggerUroboCard(than: state.calledCard), currentPlayerTakes {
            let newState = UroboState(
                playerScore: state.playerScore + 1,
                opponentScore: state.opponentScore,
                takenCards: state.takenCards,
                calledCard: -1,
                currentPlayer: state.currentPlayer
            )
            state = newState
            if state.takenCards.value.count == 12 {
                delegate?.endGame(with: newState)
            }
        } else {
            let newState = UroboState(
                playerScore: state.opponentScore + 1,
                opponentScore: state.playerScore,
                takenCards: state.takenCards,
                calledCard: -1,
                currentPlayer: state.currentPlayer == .dark ? .light : .dark
            )
            state.opponentScore += 1
            if state.takenCards.value.count == 12 {
                delegate?.endGame(with: newState)
            } else {
                delegate?.endTurn(with: newState)
            }
        }
    }
}
