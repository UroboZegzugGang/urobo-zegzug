import SwiftUI

struct UroboGameScreen: View {
    @ObservedObject var viewModel: UroboGameViewModel

    var body: some View {
        VStack {
            scoreBar()
            Spacer()
            uroboTable()
            Spacer()
            sendButton()
            helpButton()
        }
        .background {
            Color.appBackground
        }
        .overlay {
            if viewModel.helpShowing {
                howToPlay()
            }
        }
    }

    @ViewBuilder private func uroboTable() -> some View {
        ZStack {
            ForEach(0..<Constants.numberOfCards, id: \.self) { index in
                card(player: index % 2 == 0 ? .dark : .light, number: index + 1)
                    .offset(y: -Constants.cardTableHeight/2)
                    .rotationEffect(.degrees(Double(index * 360 / Constants.numberOfCards)))
            }
        }
        .frame(height: Constants.cardTableHeight)
    }

    @ViewBuilder private func card(player: UroboPlayer, number: Int) -> some View  {
        if !viewModel.takenCards.contains(number) {
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .foregroundColor(player == .light ? .gray : .black)
                .opacity(viewModel.selectedCardNumber == number ? 1 : Constants.notSelectedCardOpacity)
                .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                .shadow(radius: 0, x: Constants.shadowOffset, y: Constants.shadowOffset)
                .overlay {
                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                        .stroke(.black, lineWidth: Constants.cardBorderWidth)
                }
                .scaleEffect(viewModel.selectedCardNumber == number ? Constants.selectedCardScaleEffect : 1)
                .animation(.easeIn(duration: Constants.selectAnimationDuration), value: viewModel.selectedCardNumber)
                .onTapGesture {
                    viewModel.cardTapped(number)
                }
        }
    }

    @ViewBuilder private func scoreBar() -> some View {
        HStack {
            Text("\(viewModel.playerCurrentScore)")
                .font(.system(size: Constants.scoreValueSize, weight: .bold))
            Spacer()
            Text("Score")
                .font(.system(size: Constants.scoreTitleSize, weight: .bold))
            Spacer()
            Text("\(viewModel.opponentCurrentScore)")
                .font(.system(size: Constants.scoreValueSize, weight: .bold))
        }
        .padding()
        .padding(.horizontal)
    }

    @ViewBuilder private func sendButton() -> some View {
        Button("Send") {

        }
        .buttonStyle(MonochromeShadowButton())
        .disabled(viewModel.selectedCardNumber == nil)
    }

    @ViewBuilder private func helpButton() -> some View {
        Button {
            viewModel.helpShowing = true
        } label: {
            HStack {
                Spacer()
                SwiftUI.Circle()
                    .frame(width: Constants.helpButtonSize, height: Constants.helpButtonSize)
                    .foregroundColor(.gray)
                    .shadow(color: .black, radius: .zero, x: Constants.helpButtonShadowOffset, y: Constants.helpButtonShadowOffset)
                    .overlay {
                        Text("?")
                    }
            }
        }
        .padding()
        .foregroundColor(.white)
    }

    @ViewBuilder private func howToPlay() -> some View {
        Rectangle()
            .ignoresSafeArea()
            .opacity(.zero)
            .background(.ultraThinMaterial)
            .overlay {
                HowToPlayUroboView {
                    viewModel.helpShowing = false
                }
            }
    }
}

extension UroboGameScreen {
    private enum Constants {
        static let numberOfCards = 12
        static let cardTableHeight: CGFloat = 280
        static let cardCornerRadius: CGFloat = 10
        static let notSelectedCardOpacity: CGFloat = 0.7
        static let cardWidth: CGFloat = 40
        static let cardHeight: CGFloat = 50
        static let cardBorderWidth: CGFloat = 1
        static let shadowOffset: CGFloat = 5
        static let selectedCardScaleEffect: CGFloat = 1.3
        static let selectAnimationDuration: CGFloat = 0.1
        static let scoreTitleSize: CGFloat = 24
        static let scoreValueSize: CGFloat = 64
        static let helpButtonSize: CGFloat = 30
        static let helpButtonShadowOffset: CGFloat = 3
    }
}
