//
//  LoginViewModel.swift
//  CV
//
//  Created by Basel Al Ali on 11.04.23.
//
import Combine
import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var credentials = Credentials()
    @Published var showProgressView = false
    @Published var storeCredentialsNext = true
    @Published var error: Authentication.AuthenticationError?

    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var isSecureTextEntry = true

    @Published var userInfo: [UserInfo] = []
    @Published var isDownloadingFinished = true
    @Published var isShowingSignupView = true
    private var cancellables = Set<AnyCancellable>()

    init() {
        _ = getAllUsers()
    }

    // https://developer.apple.com/documentation/combine/using-combine-for-your-app-s-asynchronous-code#Replace-Completion-Handler-Closures-with-Futures
    private func getAllUsers() -> Future<Void, Error> {
        return Future { promise in
            guard let url = URL(string: "http://localhost:8080/users") else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
                promise(.failure(error))
                return
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard
                        let response = response as? HTTPURLResponse,
                        response.statusCode >= 200 && response.statusCode < 300 else {
                        print("Error downloading data..")
                        throw URLError(.badServerResponse)
                    }
                    return data
                }
                .decode(type: [UserInfo].self, decoder: JSONDecoder())
                .sink { [weak self] completionResult in
                    switch completionResult {
                    case .finished:
                        print("COMPLETION: \(completionResult)")
                        self?.isDownloadingFinished = true
                        promise(.success(()))
                    case let .failure(errorFailure):
                        print("COMPLETION failure: \(completionResult)")
                        self?.isDownloadingFinished = false
                        promise(.failure(errorFailure))
                    }
                } receiveValue: { [weak self] returendUserInfos in
                    self?.userInfo = returendUserInfos
                    print("ReturendUserInfos ..: \(returendUserInfos)")
                }
                .store(in: &self.cancellables)
        }
    }

    var emailInputFieldError: String? {
        guard !isEmailValid && !credentials.email.isEmpty else { return nil }

        return "Invalid email format. Please enter a valid email address."
    }

    var passwordInputFieldError: String? {
        guard !isPasswordValid && !credentials.password.isEmpty else { return nil }

        return "Invalid password format. Passwords must be at least 8 characters long and"
            + "contain at least one uppercase letter, one lowercase letter, one digit, and one special character"
    }

    var loginDisabled: Bool {
        isEmailValid && isPasswordValid
    }

    let passwordPattern = #"(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[ !$%&?._-])"#
    let emailPattern = #"^\S+@[A-Za-z0-9]+([.-][A-Za-z0-9]+)*\.[A-Za-z]{2,}$"#
    let networkingAlertMsg = "There was a problem connecting to the server. Please check your network connection and try again."
    let networkingAlertTitle = "Server Error"
    let networkingAlertBtn = "Retry"
    let uiTurquoise = UIColor(red: 0.0, green: 0.87, blue: 0.8, alpha: 1.0)
    let darkBlauUIColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)

    func login(completion: @escaping (Bool) -> Void) {
        showProgressView = true
        verfiyCredentails(credentials: credentials) { [unowned self] (result: Result<Bool, Authentication.AuthenticationError>) in
            showProgressView = false
            switch result {
            case .success:
                if storeCredentialsNext {
                    if KeychainStorage.saveCredentials(credentials) {
                        storeCredentialsNext = false
                    }
                }
                completion(true)
            case let .failure(authError):
                credentials = Credentials()
                error = authError
                completion(false)
            }
        }
    }

    func retryDownload() {
        _ = getAllUsers()
    }

    func verfiyCredentails(credentials: Credentials,
                           completion: @escaping (Result<Bool, Authentication.AuthenticationError>)
                               -> Void) {
        print("Verfiy Credentails ..")
        for user in userInfo {
            if user.username == credentials.email && user.password == credentials.password {
                completion(.success(true))
                return
            }
        }
        completion(.failure(.invalidCredentials))
    }

    func getAuthenticationResult(authentication: Authentication) {
        authentication.requestBiometricUnlock {
            (result: Result<Credentials, Authentication.AuthenticationError>) in
            switch result {
            case let .success(credentails):
                self.credentials = credentails
                self.login { success in
                    authentication.updateValidation(success: success)
                }
            case let .failure(error):
                self.error = error
            }
        }
    }

    func getBiometricAuthenticationTypeString(authentication: Authentication) -> String {
        switch authentication.biometricType() {
        case .face:
            return "Face ID"
        case .touch:
            return "Touch ID"
        case .none:
            return "No Biometric Authentication"
        }
    }

    func getBiometricAuthenticationTypeSystemImage(authentication: Authentication) -> Image {
        switch authentication.biometricType() {
        case .face:
            return Image(systemName: "faceid")
        case .touch:
            return Image(systemName: "touchid")
        case .none:
            return Image(systemName: "exclamationmark.triangle")
        }
    }

    func getAlert(error: Authentication.AuthenticationError) -> Alert {
        switch error {
        case .credentailsNotSaved:
            return Alert(title: Text("Credentials Not Saved"),
                         message: Text(error.localizedDescription),
                         primaryButton: .default(Text("OK"), action: {
                             self.storeCredentialsNext = true
                         }),
                         secondaryButton: .cancel()
            )
        default:
            return Alert(title: Text("Invalid Login"), message: Text(error.localizedDescription))
        }
    }

    func getNetworkAlert() -> Alert {
        return Alert(
            title: Text(networkingAlertTitle),
            message: Text(networkingAlertMsg),
            primaryButton: .default(Text(networkingAlertBtn)) {
                self.retryDownload()
            },
            secondaryButton: .cancel {
                self.isDownloadingFinished = true

            })
    }

    // The password is passed as a String to access the value, which input the from ui
    func checkPasswordValidity(password: String) -> Bool {
        // Find and return the range of the first occurrence of password within range of passwordPattern
        let result = password.range(
            of: passwordPattern,
            options: .regularExpression
        )

        // Return true if the password machtes the passwordPattern
        return result != nil
    }

    // The email is passed as a Binding<String> to access the value, which input the from UIView
    func checkEmailValidity(email: String) -> Bool {
        // EmailRegex will hold the reference to the created instance of NSRegularExpression
        guard let emailRegex = try? NSRegularExpression(
            pattern: emailPattern,
            options: []
        ) else {
            // Return false, if any error occurs
            return false
        }

        // Determine the source Range using NSRange for email input
        let sourceRange = NSRange(
            email.startIndex ..< email.endIndex,
            in: email
        )

        // Returns an array containing all the matches of emailRegex.
        let result = emailRegex.matches(
            in: email,
            options: [],
            range: sourceRange
        )

        // Convert the result to check the validity, if the array is not empty
        return !result.isEmpty
    }

    func emailDidChange() {
        isEmailValid = checkEmailValidity(email: credentials.email)
    }

    func passwordDidChange() {
        isPasswordValid = checkPasswordValidity(password: credentials.password)
    }

    func updateValidationByAuthention(authentication: Authentication, authenticationResult: Bool) {
        authentication.updateValidation(success: authenticationResult)
    }
}
