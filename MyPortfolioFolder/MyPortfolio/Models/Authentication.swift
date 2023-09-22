//
//  Authentication.swift
//  CV
//
//  Created by Basel Al Ali on 11.04.23.
//

import LocalAuthentication
import SwiftUI

class Authentication: ObservableObject {
    @Published var isValidated = false
    @Published var isAuthorized = false

    enum BiometricType {
        case none
        case face
        case touch
    }

    enum AuthenticationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
        case deniedAccess
        case noFaceIdEnrolled
        case noFingerprintEnrolled
        case biometricError
        case credentailsNotSaved

        var id: String {
            localizedDescription
        }

        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Either your email or password are incorrect. Please try again", comment: "")
            case .deniedAccess:
                return NSLocalizedString("You have denied access. Plase go to the settings app and locate this application and turn Face ID on", comment: "")
            case .noFaceIdEnrolled:
                return NSLocalizedString("You have not registered any Face Ids yet", comment: "")
            case .noFingerprintEnrolled:
                return NSLocalizedString("You have not registered any fingerprints yet", comment: "")
            case .biometricError:
                return NSLocalizedString("Your face or fingerprint were not recognized", comment: "")
            case .credentailsNotSaved:
                return NSLocalizedString("Your credentails have not been saved. Do you want to save them after the next successfull login?", comment: "")

            }
        }
    }

    func updateValidation(success: Bool) {
        withAnimation {
            isValidated = success
        }
    }

    func biometricType() -> BiometricType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touch
        case .faceID:
            return .face
        @unknown default:
            return .none
        }
    }

    func requestBiometricUnlock(completion: @escaping (Result<Credentials, AuthenticationError>) -> Void) {
        let credentials = KeychainStorage.getCredentials()
        guard let credentials = credentials else {
            completion(.failure(.credentailsNotSaved))
            return
        }
        let context = LAContext()
        var error: NSError?
        let canEvalute = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            switch error.code {
            case -6:
                completion(.failure(.deniedAccess))
            case -7:
                if context.biometryType == .faceID {
                    completion(.failure(.noFaceIdEnrolled))
                } else {
                    completion(.failure(.noFingerprintEnrolled))
                }
            default:
                completion(.failure(.biometricError))
            }
            return
        }
        if canEvalute {
            if context.biometryType != .none {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Need to access credentails") {
                    _, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(.biometricError))
                        } else {
                            completion(.success(credentials))
                        }
                    }
                }
            }
        }
    }
}
