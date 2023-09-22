//
//  SignupSucessed.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 12.09.23.
//

import SwiftUI

struct SignupSucessed: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                Text("Your Account has been created successfully")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)

                NavigationLink {
                    LoginView()
                } label: {
                    HStack {
                        Text("Back to login View")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }
}

struct SignupSucessed_Previews: PreviewProvider {
    static var previews: some View {
        SignupSucessed()
            .environmentObject(Authentication())
            .environmentObject(LoginViewModel())
    }
}
