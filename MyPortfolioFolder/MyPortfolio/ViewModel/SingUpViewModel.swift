//
//  SingUpViewModel.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 07.09.23.
//

import Combine
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var userInfo: UserInfo

    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var isSecureTextEntry = true
    private var cancellables = Set<AnyCancellable>()

    @FocusState var inFocus: Field?

    enum Field {
        case secure, plain
    }

    let uiTurquoise = UIColor(red: 0.0, green: 0.87, blue: 0.8, alpha: 1.0)
    let darkBlauUIColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
    let passwordPattern = #"(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[ !$%&?._-])"#
    let emailPattern = #"^\S+@[A-Za-z0-9]+([.-][A-Za-z0-9]+)*\.[A-Za-z]{2,}$"#

    init() {
        userInfo = UserInfo(username: "", password: "", firstName: "", image: nil, lastName: "")
    }

    var singupDisabled: Bool {
        isEmailValid && isPasswordValid && !userInfo.firstName.isEmpty && !userInfo.lastName.isEmpty
    }

    var emailInputFieldError: String? {
        guard !isEmailValid && !userInfo.username.isEmpty else { return nil }

        return "Invalid email format. Please enter a valid email address."
    }

    var passwordInputFieldError: String? {
        guard !isPasswordValid && !userInfo.password.isEmpty else { return nil }

        return "Invalid password format. Passwords must be at least 8 characters long and"
            + "contain at least one uppercase letter, one lowercase letter, one digit, and one special character"
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
        isEmailValid = checkEmailValidity(email: userInfo.username)
    }

    func passwordDidChange() {
        isPasswordValid = checkPasswordValidity(password: userInfo.password)
    }

    func createUserAndHandelResponse(userInfo: UserInfo) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "http://localhost:8080/user") else {
            return Fail<Void, Error>(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        do {
            let userData = try JSONEncoder().encode(userInfo)
            let jsonString = String(data: userData, encoding: .utf8)
            print("JSON Data to Send: \(jsonString ?? "")")
            request.httpBody = userData

            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200 ..< 300).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    return data
                }
                .map { _ in () }
                .eraseToAnyPublisher()

        } catch {
            return Fail<Void, Error>(error: error).eraseToAnyPublisher()
        }
    }

    func creatUser(userInfo: UserInfo) {
        createUserAndHandelResponse(userInfo: userInfo)
            .sink { completionResult in
                switch completionResult {
                case .finished:
                    print("User creation completed successfully.")
                case let .failure(completionError):
                    print("COMPLETION failure: \(completionError)")
                }
            } receiveValue: { _ in
                print("receiveValue .. ")
            }
            .store(in: &cancellables)
    }
}
