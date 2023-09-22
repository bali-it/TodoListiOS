//
//  UserInfo.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 06.09.23.
//

import Foundation

struct UserInfo: Codable {
    var username, password, firstName: String
    var image: String?
    var lastName: String

    init(username: String, password: String, firstName: String, image: String? = nil, lastName: String) {
        self.username = username
        self.password = password
        self.firstName = firstName
        self.image = image
        self.lastName = lastName
    }
}
