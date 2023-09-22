//
//  CVApp.swift
//  CV
//
//  Created by Basel Al Ali on 29.12.22.
//

import SwiftUI

@main
struct MyPortfolio_App: App {
    
    @StateObject var authentication = Authentication()
    @StateObject var listViewModel = ListViewModel()

    var body: some Scene {
        WindowGroup {
            if authentication.isValidated {
                MainView()
                    .environmentObject(authentication)
                    .environmentObject(listViewModel)
            } else {
                LoginView()
                    .environmentObject(authentication)
            }
        }
    }
}
