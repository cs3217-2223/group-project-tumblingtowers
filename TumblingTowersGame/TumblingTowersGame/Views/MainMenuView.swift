//
//  MainMenuView.swift
//  TumblingTowersGame
//
//  Created by Elvis on 29/3/23.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var mainGameMgr: MainGameManager

    @Binding var currGameScreen: Constants.CurrGameScreens

    var body: some View {
        ZStack {
            BackgroundView()

            VStack {
                Spacer()

                Image(ViewImageManager.mainLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 500)

                Spacer()

                createButton(label: "Play", destination: .playerOptionSelection)

                Spacer().frame(height: 50)

                createButton(label: "Achievements", destination: .achievements)

                Spacer().frame(height: 50)

                createButton(label: "Settings", destination: .settings)

                Spacer()
                Spacer()
            }

            GeometryReader { geo in
                Button {
                    withAnimation {
                        currGameScreen = .tutorial
                    }
                } label: {
                    Text("?")
                        .modifier(SquareCustomButton(fontSize: 50))
                }
                .modifier(SquareCustomButton(fontSize: 50))
                .position(x: geo.size.width - 100, y: geo.size.height - 100)
            }

        }
        .ignoresSafeArea(.all)
    }

    private func createButton(label: String, destination: Constants.CurrGameScreens) -> AnyView {
        AnyView(
            Button {
                withAnimation {
                    currGameScreen = destination
                }
            } label: {
                Text(label)
                    .modifier(CustomButton(fontSize: 40))
            }
            .modifier(CustomButton(fontSize: 40))
        )
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(currGameScreen: .constant(.mainMenu))
            .environmentObject(MainGameManager())
    }
}
