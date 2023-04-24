import SwiftUI

struct MenuScreen: View {
    let viewModel: MenuViewModel

    var body: some View {
        HStack {
            Spacer()
            uroboTile()
            Spacer()
            zegzugTile()
            Spacer()
        }
        .padding(Padding.single)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    @ViewBuilder private func uroboTile() -> some View {
        GameMenuButton(gameType: .urobo) {
            viewModel.startUrobo()
        }
    }

    @ViewBuilder private func zegzugTile() -> some View {
        GameMenuButton(gameType: .zegzug) {
            viewModel.startZegZug()
        }
    }
}
