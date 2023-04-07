//
//  MenuScreen.swift
//  urobo-zegzug MessagesExtension
//
//  Created by Váczi Samu on 2023. 04. 07..
//

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
        .background(Color("appBackground"))
    }

    @ViewBuilder private func uroboTile() -> some View {
        GameMenuTile(title: "Urobo", graphic: Image("uroboGraphic"), backgroundColor: Color("menuTileBackground"))
            .onTapGesture {
                viewModel.startUrobo()
            }
    }

    @ViewBuilder private func zegzugTile() -> some View {
        GameMenuTile(title: "ZegZug", graphic: Image("zegzugGraphic"), backgroundColor: Color("menuTileBackground"))
            .onTapGesture {
                viewModel.startZegZug()
            }
    }
}

struct MenuScreen_Previews: PreviewProvider {
    static var previews: some View {
        MenuScreen(viewModel: MenuViewModel())
    }
}
