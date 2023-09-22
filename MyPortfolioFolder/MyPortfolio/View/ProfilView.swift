//
//  ProfilView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 05.07.23.
//

import SwiftUI

struct ProfilView: View {
    
    @EnvironmentObject var authentication: Authentication

    var body: some View {

        Button {
            authentication.updateValidation(success: false)
        } label: {
            Text("log out".uppercased())
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("StartView.logout.btn")
    }
}

struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfilView()
                .environmentObject(Authentication())
        }
    }
}
