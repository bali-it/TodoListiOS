//
//  LoginAlerts.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 11.09.23.
//

import SwiftUI

struct LoginAlerts: View {
    @State var showErrorAlert: Bool
    @StateObject var vm: LoginViewModel
    @EnvironmentObject var authentication: Authentication

    var body: some View {
        Group {
            if showErrorAlert {
                vm.getNetworkAlert()
            } else if let error = vm.error {
                vm.getAlert(error: error)
            }
        }
    }
}

struct LoginAlerts_Previews: PreviewProvider {
    static var previews: some View {
        LoginAlerts(showErrorAlert: .constant(true), vm: LoginViewModel())
            .environmentObject(Authentication())
            .environmentObject(LoginViewModel())
    }
}
