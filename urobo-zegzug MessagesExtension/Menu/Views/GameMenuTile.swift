//
//  GameMenuTile.swift
//  urobo-zegzug MessagesExtension
//
//  Created by Váczi Samu on 2023. 04. 07..
//

import SwiftUI

struct GameMenuTile: View {
    @GestureState private var isBeingTapped = false

    let title: String
    let graphic: Image
    let backgroundColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(width: Constants.size, height: Constants.size)
                .offset(x: Constants.shadowOffset, y: Constants.shadowOffset)
                .foregroundColor(.black)

            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .frame(width: Constants.size, height: Constants.size)
                .foregroundColor(backgroundColor)
                .overlay {
                    VStack {
                        Text(title)
                            .font(.system(size: Constants.titleSize, weight: .bold))

                        graphic
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(Padding.double)
                }
        }
        .scaleEffect(isBeingTapped ? Constants.tappedStateScaleValue : 1.0)
        .animation(.easeIn(duration: Constants.animationDuration), value: isBeingTapped)
        .gesture(LongPressGesture(minimumDuration: Constants.pressMinDuration).sequenced(before:DragGesture(minimumDistance: .zero))
            .updating($isBeingTapped) { value, state, _ in
                switch value {
                case .second(true, nil):
                    state = true
                default:
                    break
                }
            })
    }
}

extension GameMenuTile {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let size: CGFloat = 120
        static let shadowOffset: CGFloat = 5
        static let titleSize: CGFloat = 16
        static let tappedStateScaleValue: CGFloat = 1.1
        static let animationDuration: CGFloat = 0.1
        static let pressMinDuration: CGFloat = 0.01
    }
}

struct GameMenuTile_Previews: PreviewProvider {
    static var previews: some View {
        GameMenuTile(title: "Urobo", graphic: Image("uroboGraphic"), backgroundColor: Color("menuTileBackground"))
    }
}
