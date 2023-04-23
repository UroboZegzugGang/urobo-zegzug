import SwiftUI

struct GameMenuButton: View {
    @GestureState private var isBeingTapped = false

    let gameType: GameType
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .frame(width: Constants.size, height: Constants.size)
                    .offset(x: Constants.shadowOffset, y: Constants.shadowOffset)
                    .foregroundColor(.black)

                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .frame(width: Constants.size, height: Constants.size)
                    .foregroundColor(.menuTileBackground)
                    .overlay {
                        VStack {
                            Text(gameType.name)
                                .font(.system(size: Constants.titleSize, weight: .bold))

                            graphic()
                        }
                        .padding(Padding.double)
                    }
            }
        }
        .buttonStyle(ScaleOnTap())
    }

    @ViewBuilder private func graphic() -> some View {
        switch gameType {
        case .urobo:
            Image.uroboGraphic
                .resizable()
                .scaledToFit()
        case .zegzug:
            Image.zegZugGraphic
                .resizable()
                .scaledToFit()
        }
    }
}

extension GameMenuButton {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let size: CGFloat = 120
        static let shadowOffset: CGFloat = 5
        static let titleSize: CGFloat = 16
    }
}

struct GameMenuTile_Previews: PreviewProvider {
    static var previews: some View {
        GameMenuButton(gameType: .urobo) {}
    }
}
