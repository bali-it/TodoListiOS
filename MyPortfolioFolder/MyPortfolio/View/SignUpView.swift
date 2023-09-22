//
//  SignUpView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 07.09.23.
//

import SwiftUI
import UIKit

struct SignUpView: View {
    @StateObject private var vm = SignUpViewModel()
    @State private var imageText: String?
    @FocusState var inFocus: Field?

    enum Field {
        case secure, plain
    }

    var body: some View {
        NavigationStack {
            VStack {
                Image("signup")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }

                Divider()
                ScrollView {
                    VStack(spacing: 20) {
                        emailInputField
                        passwordInputField
                        firstNameInputField
                        lastNameInputField
                        imageInputField

                        Spacer()
                        signUpButton
                    }
                }
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(Authentication())
            .environmentObject(LoginViewModel())
    }
}

extension SignUpView {
    private var emailInputField: some View {
        VStack(spacing: 3) {
            TextField("Email Address", text: $vm.userInfo.username)
                .keyboardType(.emailAddress)
                .modifier(CustomViewModifier(
                    roundedCorns: 0,
                    startColor: Color(vm.darkBlauUIColor),
                    endColor: Color(vm.uiTurquoise),
                    textColor: Color("AccentColor"))
                )
                .accessibilityIdentifier("Sign.up.email.input")

            if let emailError = vm.emailInputFieldError {
                Text(emailError)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("Sign.up.email.error")
            }
        }
        .onChange(of: vm.userInfo.username) { _ in
            vm.emailDidChange()
        }
    }

    private var passwordInputField: some View {
        VStack {
            ZStack(alignment: .trailing) {
                Group {
                    if vm.isSecureTextEntry {
                        SecureField("Password", text: $vm.userInfo.password)
                            .modifier(CustomViewModifier(
                                roundedCorns: 0,
                                startColor: Color(vm.darkBlauUIColor),
                                endColor: Color(vm.uiTurquoise),
                                textColor: Color("AccentColor"))
                            )
                            .focused($inFocus, equals: .secure)
                            .accessibilityIdentifier("LoginView.password.input.SecureTextEntry")
                    } else {
                        TextField("Password", text: $vm.userInfo.password)
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
        .onChange(of: vm.userInfo.password) { _ in
            vm.passwordDidChange()
        }
    }

    private var firstNameInputField: some View {
        TextField("First Name", text: $vm.userInfo.firstName)
            .modifier(CustomViewModifier(
                roundedCorns: 0,
                startColor: Color(vm.darkBlauUIColor),
                endColor: Color(vm.uiTurquoise),
                textColor: Color("AccentColor"))
            )
            .accessibilityIdentifier("Sign.up.first.name")
    }

    private var lastNameInputField: some View {
        TextField("Last Name", text: $vm.userInfo.lastName)
            .modifier(CustomViewModifier(
                roundedCorns: 0,
                startColor: Color(vm.darkBlauUIColor),
                endColor: Color(vm.uiTurquoise),
                textColor: Color("AccentColor"))
            )
            .accessibilityIdentifier("Sign.up.last.name")
    }

    private var imageInputField: some View {
        TextField("Image URL (Optional)", text: Binding(
            get: {
                imageText ?? ""
            },
            set: {
                imageText = $0
            }
        )).modifier(CustomViewModifier(
            roundedCorns: 0,
            startColor: Color(vm.darkBlauUIColor),
            endColor: Color(vm.uiTurquoise),
            textColor: Color("AccentColor"))
        )
        .accessibilityIdentifier("Sign.up.image")
    }

    private var signUpButton: some View {
        NavigationLink(
            destination:
            SignupSucessed(),
            label: {
                HStack {
                    Text("sign in".uppercased())
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding()
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(vm.singupDisabled ? Color.accentColor : Color.gray)
                        .shadow(radius: 3)
                )
                .accessibilityIdentifier("Sign.up.login.label")
            })
            .disabled(!vm.singupDisabled)
            .simultaneousGesture(TapGesture().onEnded({
                vm.creatUser(userInfo: vm.userInfo)
            }))
    }
}
