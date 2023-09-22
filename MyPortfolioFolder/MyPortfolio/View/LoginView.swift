//
//  ContentView.swift
//  CV
//
//  Created by Basel Al Ali on 29.12.22.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    @EnvironmentObject var authentication: Authentication
    @Environment(\.colorScheme) var colorScheme
    @State private var showDownloadingAlert = false
    @FocusState var inFocus: Field?

    enum Field {
        case secure, plain
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack {
                        Spacer()
                        LoginHeaderView()
                        Spacer()
                            .padding(.bottom, 20)

                        emailInputField
                        passwordInputField

                        if vm.showProgressView {
                            ProgressView()
                        }
                        Spacer()
                            .padding(.bottom, 30)

                        loginButtonView

                        if authentication.biometricType() != .none {
                            Button {
                                vm.getAuthenticationResult(authentication: authentication)
                            } label: {
                                labelBiometricSection
                            }.background(
                                 RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color("AccentColor"))
                                .frame(width: 350, height: 37)
                            )
                            .padding(.bottom, 140)
                        }
                        singUpSection
                    }
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(vm.showProgressView)
                    .alert(item: $vm.error) { error in
                        vm.getAlert(error: error)
                    }
                    ZStack {
                        if !vm.isDownloadingFinished {
                            Color.white.opacity(0.7)
                                .ignoresSafeArea(.all)

                            Section {
                                ProgressView("")
                                    .font(.caption)
                                    .scaleEffect(2)
                                    .foregroundColor(Color.red)
                                    .zIndex(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                            if !vm.isDownloadingFinished {
                                showDownloadingAlert = true
                            }
                        }
                    }
                    .alert(isPresented: $showDownloadingAlert) {
                        vm.getNetworkAlert()
                    }
                }
            }
            .navigationBarTitle("login View".uppercased(), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(Authentication())
    }
}

extension LoginView {
    private var emailInputField: some View {
        VStack(spacing: 3) {
            TextField("Email Address", text: $vm.credentials.email)
                .keyboardType(.emailAddress)
                .modifier(CustomViewModifier(
                    roundedCorns: 0,
                    startColor: Color(vm.darkBlauUIColor),
                    endColor: Color(vm.uiTurquoise),
                    textColor: Color("AccentColor"))
                )
                .accessibilityIdentifier("LoginView.email.input")

            if let emailError = vm.emailInputFieldError {
                Text(emailError)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("LoginView.email.error")
            }
        }
        .onChange(of: vm.credentials.email) { _ in
            vm.emailDidChange()
        }
    }

    private var passwordInputField: some View {
        VStack {
            ZStack(alignment: .trailing) {
                Group {
                    if vm.isSecureTextEntry {
                        SecureField("Password", text: $vm.credentials.password)
                            .modifier(CustomViewModifier(
                                roundedCorns: 0,
                                startColor: Color(vm.darkBlauUIColor),
                                endColor: Color(vm.uiTurquoise),
                                textColor: Color("AccentColor"))
                            )
                            .focused($inFocus, equals: .secure)
                            .accessibilityIdentifier("LoginView.password.input.SecureTextEntry")
                    } else {
                        TextField("Password", text: $vm.credentials.password)
                            .modifier(CustomViewModifier(
                                roundedCorns: 0,
                                startColor: Color(vm.darkBlauUIColor),
                                endColor: Color(vm.uiTurquoise),
                                textColor: Color("AccentColor"))
                            )
                            .focused($inFocus, equals: .plain)
                            .accessibilityIdentifier("LoginView.password.input.visible")
                    }
                }
                Button(action: {
                    vm.isSecureTextEntry.toggle()
                    inFocus = vm.isSecureTextEntry ? .secure : .plain

                }, label: {
                    Image(systemName: vm.isSecureTextEntry ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                }
                )
                .padding(.trailing, 20)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            if let passwordError = vm.passwordInputFieldError {
                Text(passwordError)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("LoginView.password.error")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: vm.credentials.password) { _ in
            vm.passwordDidChange()
        }
    }

    private var loginButtonView: some View {
        Button("Log in".uppercased()) {
            vm.login { success in
                vm.updateValidationByAuthention(
                    authentication: authentication,
                    authenticationResult: success)
            }
        }
        .font(.headline)
        .foregroundColor(Color.white)
        .cornerRadius(10)
        .disabled(!vm.loginDisabled)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(vm.loginDisabled ? Color.accentColor : Color.gray)
            .frame(width: 222, height: 22)
        )
        .scaleEffect(1.6)
        .padding(.bottom, 20)
        .font(.headline)
        .accessibilityIdentifier("LoginView.login.button")
    }

    private var labelBiometricSection: some View {
        return HStack(spacing: 10) {
            Text(vm.getBiometricAuthenticationTypeString(authentication: authentication))
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .accessibilityIdentifier("LoginView.alert.id")

            vm.getBiometricAuthenticationTypeSystemImage(authentication: authentication)
                .resizable()
                .foregroundColor(Color.white)
                .frame(width: 30, height: 30)
                .accessibilityIdentifier("LoginView.alert.image")
        }
    }

    private var singUpSection: some View {
        VStack {
            HStack(spacing: 10) {
                Text("No Account?")
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundColor(Color("AccentColor"))
                    .accessibilityIdentifier("LoginView.noAccount")
                NavigationLink(destination: SignUpView(), label: {
                    HStack {
                        Text("Register Here")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(Font.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("AccentColor"))
                            .shadow(radius: 3))
                }
                )
            }
        }
    }
}
