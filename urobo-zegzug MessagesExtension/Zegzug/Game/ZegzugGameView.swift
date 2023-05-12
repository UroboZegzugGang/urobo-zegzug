import SwiftUI

struct ZegzugGameView: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        VStack {
            Spacer()
            turnTitle()
            resetButton()
            BackgroundCircles()
                .background {
                    PlayableArea(viewModel: viewModel)
                }
                .rotationEffect(Angle(degrees: -15))
            Spacer()
            sendButton()
            infoButton()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.appBackground.ignoresSafeArea()
        }
        .overlay {
            if viewModel.showingHowTo {
                howToPanel()
            }
        }
    }

    @ViewBuilder private func turnTitle() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.turnState.title)
                .font(.largeTitle)
                .bold()
            if viewModel.placedPebbles != viewModel.numOfPebbles {
                Text("Placed: \(viewModel.placedPebbles) out of \(viewModel.numOfPebbles)")
                    .font(.subheadline)
            }
        }
    }

    @ViewBuilder private func resetButton() -> some View {
        HStack {
            Spacer()
            Button {
                viewModel.resetToLastSate()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.circular)
        }
    }

    @ViewBuilder private func sendButton() -> some View {
        Button("Send") {
            viewModel.sendAction()
        }
        .buttonStyle(.monochromeShadow)
        .disabled(!viewModel.canSend)
        .padding(.top)
    }

    @ViewBuilder private func infoButton() -> some View {
        HStack {
            Spacer()
            Button("?") {
                viewModel.showingHowTo = true
            }
            .buttonStyle(.circular)
        }
    }

    @ViewBuilder private func howToPanel() -> some View {
        Rectangle()
            .ignoresSafeArea()
            .opacity(.zero)
            .background(.ultraThinMaterial)
            .overlay {
                HowToPlayView(gameType: .zegzug) {
                    viewModel.showingHowTo = false
                }
            }
    }
}
