import SwiftUI

struct HowToPlayView: View {
    let gameType: GameType
    var hideAction: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(maxWidth: Constants.width, maxHeight: Constants.height)
                .foregroundColor(.black)
                .offset(x: Constants.shadowOffset, y: Constants.shadowOffset)

            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(maxWidth: Constants.width, maxHeight: Constants.height)
                .foregroundColor(.menuTileBackground)
                .overlay {
                    infoPanel()
                }
        }
    }

    @ViewBuilder private func infoPanel() -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                closeButton()
                Text("How to play \(gameType.name)")
                    .font(.system(size: Constants.titleSize, weight: .bold))
                    .padding([.bottom, .horizontal], Padding.triple)
                VStack(alignment: .leading) {
                    switch gameType {
                    case .urobo:
                        uroboGameDescription()
                    case .zegzug:
                        zegzugGameDescription()
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder private func uroboGameDescription() -> some View {
        Group {
            sectionHeader("Dark plays against light")
            sectionBody("There are no strongest or weakest tiles. The strength of each tile depends on their position to the one that had been laid.")

            sectionHeader("The stonger wins the trick")
            sectionBody("The ones that follow the played one clockwise are stronger, and the other ones counter-clockwise are weaker.")

            sectionHeader("You can pass a trick by playing a weaker tile")
            sectionBody("Try to pass a trick to avoid leading the next one.")

            sectionHeader("Whoever wins a trick leads the next one")
            sectionBody("Remember you can always lead a weak tile.")

            sectionHeader("Whoever wins more tricks wins the deal")
            sectionBody("In case of equality the one who won the last trick wins the deal.")
        }
    }

    @ViewBuilder private func zegzugGameDescription() -> some View {
        Group {
            sectionHeader("Two players play against eachother")
            sectionBody("Both players have the same amount of pebbles (6-12). These can be placed and moved on the board.")

            sectionHeader("Placement of the pebbles")
            sectionBody("Players take turns placing their pebbles one by one. If all pebbles have been placed they can be moved to neighbouring places marked by orange or green lines. There can only be one pebble per place. Pebbles can't jump over eachother.")

            sectionHeader("Turns")
            sectionBody("After placing the pebbles players can move a single pebble by a single place each turn.")

            sectionHeader("Who wins")
            sectionBody("The first player to have 5 pebbles next to eachother by the orange or green lines wins. Lines can't be mixed. It has to be 5 pebbles connected by just orange or just green lines. It has to be in a straigth line without interesctions.")
        }
    }

    @ViewBuilder private func closeButton() -> some View {
        HStack {
            Spacer()
            Button("X") {
                hideAction()
            }
            .buttonStyle(.circular)
            .padding(.trailing, Padding.half)
        }
    }

    @ViewBuilder private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: Constants.sectionHeaderSize, weight: .medium))
            .padding(.top)
            .padding(.bottom, Padding.half)
    }

    @ViewBuilder private func sectionBody(_ text: String) -> some View {
        Text(text)
            .font(.system(size: Constants.sectionBodySize))
    }
}

extension HowToPlayView {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let width: CGFloat = 300
        static let height: CGFloat = 500
        static let shadowOffset: CGFloat = 8
        static let titleSize: CGFloat = 24
        static let sectionHeaderSize: CGFloat = 20
        static let sectionBodySize: CGFloat = 14
        static let closeButtonSize: CGFloat = 30
    }
}
