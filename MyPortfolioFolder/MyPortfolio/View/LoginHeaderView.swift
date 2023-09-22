//
//  LoginHeaderView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 24.08.23.
//

import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        Image("Inside")
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(
                        UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
    }
}

struct LoginHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeaderView()
    }
}
