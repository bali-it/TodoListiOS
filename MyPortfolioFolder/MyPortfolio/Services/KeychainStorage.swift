//
//  KeychainStorage.swift
//  CV
//
//  Created by Basel Al Ali on 25.04.23.
//

import Foundation
import SwiftKeychainWrapper

enum KeychainStorage {
    static let key = "credentials"

    static func getCredentials() -> Credentials? {
        if let myCredentialsString = KeychainWrapper.standard.string(forKey: Self.key) {
            return Credentials.decode(myCredentialsString)
        } else {
            return nil
        }
    }

    static func saveCredentials(_ credentials: Credentials) -> Bool {
        if KeychainWrapper.standard.set(credentials.encode(), forKey: Self.key) {
            return true
        } else {
            return false
        }
    }
}
