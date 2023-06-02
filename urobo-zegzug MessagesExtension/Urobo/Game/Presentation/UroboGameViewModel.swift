import Foundation

protocol UroboGameViewModelDelegate {
    func endTurn(with state: UroboState)
}

final class UroboGameViewModel: ObservableObject {
    var delegate: UroboGameViewModelDelegate?

    @Published private(set) var state: UroboState
    @Published var helpShowing: Bool = false
    @Published var selectedCardNumber: Int?
    @Published var gameWinner: UroboPlayer?

    init(state: UroboState) {
        self.state = state
        self.gameWinner = state.winner
    }

    func cardTapped(_ number: Int) {
        guard playerOfCard(number) == state.currentPlayer, gameWinner == nil else { return }
        if selectedCardNumber == number {
            selectedCardNumber = nil
        } else {
            selectedCardNumber = number
        }
    }

    func choosePressed() {
        guard selectedCardNumber != nil, gameWinner == nil else { return }
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
            currentPlayer: state.currentPlayer.opposite,
            winner: nil
        )
        delegate?.endTurn(with: newState)
    }

    private func answer() {
        guard let selectedCardNumber else { return }
        state.takenCards.addElements(of: [selectedCardNumber, state.calledCard])

        if let currentPlayerTakes = selectedCardNumber.isBiggerUroboCard(than: state.calledCard), currentPlayerTakes {
            let playerScore = state.playerScore + 1
            let opponentScore = state.opponentScore
            var winner: UroboPlayer?
            if playerScore >= 4 || (playerScore == 3 && opponentScore == 3) {
                winner = state.currentPlayer
            }

            if let winner {
                delegate?.endTurn(with: createNewStateOnAnswer(playerScore: playerScore, opponentScore: opponentScore, switchingPlayers: true, winner: winner))
            } else {
                state = createNewStateOnAnswer(playerScore: playerScore, opponentScore: opponentScore)
            }
            self.selectedCardNumber = nil
        } else {
            let playerScore = state.playerScore
            let opponentScore = state.opponentScore + 1
            var winner: UroboPlayer?
            if opponentScore >= 4 || (opponentScore == 3 && playerScore == 3) {
                winner = state.currentPlayer.opposite
            }
            state.opponentScore = opponentScore
            delegate?.endTurn(with: createNewStateOnAnswer(playerScore: playerScore, opponentScore: opponentScore, switchingPlayers: true, winner: winner))
        }
    }

    private func createNewStateOnAnswer(
        playerScore: Int,
        opponentScore: Int,
        switchingPlayers: Bool = false,
        winner: UroboPlayer? = nil
    ) -> UroboState {
        return UroboState(
            playerScore: switchingPlayers ? opponentScore : playerScore,
            opponentScore: switchingPlayers ? playerScore : opponentScore,
            takenCards: state.takenCards,
            calledCard: -1,
            currentPlayer: switchingPlayers ? state.currentPlayer.opposite : state.currentPlayer,
            winner: winner
        )
    }
}
