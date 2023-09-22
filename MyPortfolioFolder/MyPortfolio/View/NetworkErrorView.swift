//
//  NetworkErrorView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 06.09.23.
//

import SwiftUI

struct NetworkErrorView: View {
    
    @StateObject private var vm = LoginViewModel()
    @State private var isNetworkErrorAlertPresented = true
    
    var body: some View {
        Button("Trigger Network Error") {
        }.alert(isPresented: $isNetworkErrorAlertPresented) {
            Alert(
                title: Text("Network Error"),
                message: Text("There was a problem connecting to the server. Please check your network connection and try again."),
                primaryButton: .default(Text("Retry")) {
                    vm.retryDownload()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func handelNetworkError(_ error: Error){
        print("Network error \(error)")
        isNetworkErrorAlertPresented = true
    }
}

struct NetworkErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkErrorView()
    }
}
