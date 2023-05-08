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
        guard let calledCard = state.calledCard else {
            return
        }
        if calledCard == -1 {
            call()
        } else {
            answer()
        }
    }

    func isCardTaken(_ card: Int) -> Bool {
        guard let takenCards = state.takenCards else {
            return true
        }
        return takenCards.contains(card)
    }

    func playerOfCard(_ card: Int) -> UroboPlayer {
        card % 2 == 0 ? .dark : .light
    }

    private func call() {
        guard let takenCards = state.takenCards,
              let playerScore = state.playerScore,
              let opponentScore = state.opponentScore,
              let currentPlayer = state.currentPlayer,
              let selectedCardNumber else {
            return
        }

        let newState = UroboState(
            playerScore: opponentScore,
            opponentScore: playerScore,
            takenCards: takenCards,
            calledCard: selectedCardNumber,
            currentPlayer: currentPlayer == .dark ? .light : .dark
        )
        delegate?.endTurn(with: newState)
    }

    private func answer() {
        guard let playerScore = state.playerScore,
              let opponentScore = state.opponentScore,
              let currentPlayer = state.currentPlayer,
              let selectedCardNumber,
              let calledCard = state.calledCard else {
            return
        }
        state.takenCards?.addElements(of: [selectedCardNumber, calledCard])
        guard let takenCards = state.takenCards else { return }

        if let currentPlayerTakes = selectedCardNumber.isBiggerUroboCard(than: calledCard), currentPlayerTakes {
            let newState = UroboState(
                playerScore: playerScore + 1,
                opponentScore: opponentScore,
                takenCards: takenCards,
                calledCard: -1,
                currentPlayer: currentPlayer
            )
            state = newState
            if state.takenCards?.value.count == 12 {
                delegate?.endGame(with: newState)
            }
        } else {
            let newState = UroboState(
                playerScore: opponentScore + 1,
                opponentScore: playerScore,
                takenCards: takenCards,
                calledCard: -1,
                currentPlayer: currentPlayer == .dark ? .light : .dark
            )
            state.opponentScore? += 1
            if state.takenCards?.value.count == 12 {
                delegate?.endGame(with: newState)
            } else {
                delegate?.endTurn(with: newState)
            }
        }
    }
}
