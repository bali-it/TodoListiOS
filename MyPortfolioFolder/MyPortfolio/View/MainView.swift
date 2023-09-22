//
//  MainView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 01.07.23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authentication: Authentication

    var body: some View {
        TabView {
            StartView()
                .tabItem {
                    Label("List", systemImage: "list.dash")
                }
            if authentication.isValidated {
                ProfilView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
            }

        }.accentColor(Color.accentColor)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(ListViewModel())
            .environmentObject(Authentication())
    }
}
