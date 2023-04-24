import SwiftUI

struct ZegzugGameView: View {
    @StateObject var viewModel: ZegzugGameViewModel

    var body: some View {
        VStack {
            resetButton()
            BackgroundCircles()
                .background {
                    PlayableArea(viewModel: viewModel)
                }
            sendButton()
        }
    }

    @ViewBuilder private func resetButton() -> some View {
        HStack {
            Spacer()
            Button("Reset") {
                // TODO: reset current turn
            }
        }
        .padding(.trailing)
    }

    @ViewBuilder private func sendButton() -> some View {
        Button("Send") {
            // TODO: End turn and send it
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}
