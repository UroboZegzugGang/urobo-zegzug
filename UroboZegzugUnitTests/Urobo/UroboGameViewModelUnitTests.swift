@testable import urobo_zegzug_MessagesExtension
import XCTest

final class UroboGameViewModelUnitTests: XCTestCase {
    private var viewModel: UroboGameViewModel!

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_cardTapped_whenCalled_withNoSelectedCardBefore_thenCardIsSelected() {
        makeSut(
            with: UroboState(
                playerScore: .zero,
                opponentScore: .zero,
                takenCards: .init(value: []),
                calledCard: -1,
                currentPlayer: .dark,
                winner: nil
            )
        )
        viewModel.selectedCardNumber = nil
        viewModel.cardTapped(2)
        XCTAssertNotNil(viewModel.selectedCardNumber)
        XCTAssertEqual(viewModel.selectedCardNumber, 2)
    }

    func test_cardTapped_whenCalled_withSelectedCardBefore_thenCardIsUnelected() {
        makeSut(
            with: UroboState(
                playerScore: .zero,
                opponentScore: .zero,
                takenCards: .init(value: []),
                calledCard: -1,
                currentPlayer: .dark,
                winner: nil
            )
        )
        viewModel.selectedCardNumber = 2
        viewModel.cardTapped(2)
        XCTAssertNil(viewModel.selectedCardNumber)
    }

    func test_cardTapped_whenCalled_withOtherPlayersCard_thenNothingIsSelected() {
        makeSut(
            with: UroboState(
                playerScore: .zero,
                opponentScore: .zero,
                takenCards: .init(value: []),
                calledCard: -1,
                currentPlayer: .dark,
                winner: nil
            )
        )
        viewModel.selectedCardNumber = nil
        viewModel.cardTapped(1)
        XCTAssertNil(viewModel.selectedCardNumber)
    }

    func test_choosePressed_whenCalled_whenAnswering_withBiggerCard_thenScoreIsUpdated() {
        makeSut(
            with: UroboState(
                playerScore: .zero,
                opponentScore: .zero,
                takenCards: .init(value: []),
                calledCard: 2,
                currentPlayer: .light,
                winner: nil
            )
        )
        viewModel.selectedCardNumber = 3
        viewModel.choosePressed()
        XCTAssertEqual(viewModel.state.playerScore, 1)
        XCTAssertEqual(viewModel.state.opponentScore, .zero)
    }

    func test_choosePressed_whenCalled_whenAnswering_withBiggerCard_thenPlayerCanCallNextCard() {
        makeSut(
            with: UroboState(
                playerScore: .zero,
                opponentScore: .zero,
                takenCards: .init(value: []),
                calledCard: 2,
                currentPlayer: .light,
                winner: nil
            )
        )
        viewModel.selectedCardNumber = 3
        viewModel.choosePressed()
        XCTAssertEqual(viewModel.state.currentPlayer, .light)
        XCTAssertNil(viewModel.selectedCardNumber)
    }

    func test_choosePressed_whenCalled_whenAnswering_thenCalledCardsIsUpdated() {
        makeSut(
            with: UroboState(
                playerScore: .zero,
                opponentScore: .zero,
                takenCards: .init(value: []),
                calledCard: 2,
                currentPlayer: .light,
                winner: nil
            )
        )
        viewModel.selectedCardNumber = 3
        viewModel.choosePressed()
        XCTAssertTrue(viewModel.state.takenCards.contains(2))
        XCTAssertTrue(viewModel.state.takenCards.contains(3))
    }

    private func makeSut(with state: UroboState) {
        viewModel = UroboGameViewModel(state: state)
    }
}
