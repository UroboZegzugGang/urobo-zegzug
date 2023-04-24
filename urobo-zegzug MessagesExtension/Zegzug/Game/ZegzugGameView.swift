import SwiftUI

struct ZegzugGameView: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        VStack {
            Spacer()
            resetButton()
            BackgroundCircles()
                .background {
                    PlayableArea(viewModel: viewModel)
                }
            Spacer()
            sendButton()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.appBackground.ignoresSafeArea()
        }
    }

    @ViewBuilder private func resetButton() -> some View {
        HStack {
            Spacer()
            Button("Reset") {
                // TODO: reset current turn
            }
        }
    }

    @ViewBuilder private func sendButton() -> some View {
        Button("Send") {
            // TODO: End turn and send it
        }
        .buttonStyle(MonochromeShadowButton())
        .padding(.top)
    }
}
