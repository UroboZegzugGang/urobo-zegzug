//
//  HowToPlayUroboView.swift
//  urobo-zegzug MessagesExtension
//
//  Created by Váczi Samu on 2023. 04. 08..
//

import SwiftUI

struct HowToPlayUroboView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(maxWidth: Constants.width, maxHeight: Constants.height)
                .foregroundColor(.black)
                .offset(x: Constants.shadowOffset, y: Constants.shadowOffset)

            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(maxWidth: Constants.width, maxHeight: Constants.height)
                .foregroundColor(.white)
                .overlay {
                    gameDescription()
                }
        }
    }

    @ViewBuilder private func gameDescription() -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("How to play Urobo")
                    .font(.system(size: Constants.titleSize, weight: .bold))
                    .padding(Padding.triple)
                VStack(alignment: .leading) {
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
        }
        .padding()
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

extension HowToPlayUroboView {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let width: CGFloat = 300
        static let height: CGFloat = 500
        static let shadowOffset: CGFloat = 8
        static let titleSize: CGFloat = 24
        static let sectionHeaderSize: CGFloat = 20
        static let sectionBodySize: CGFloat = 14
    }
}

struct HowToPlayUroboView_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayUroboView()
    }
}
