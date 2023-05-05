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
            Button {
                // TODO: reset current turn
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.circular)
        }
    }

    @ViewBuilder private func sendButton() -> some View {
        Button("Send") {
            // TODO: End turn and send it
        }
        .buttonStyle(.monochromeShadow)
        .padding(.top)
    }
}
