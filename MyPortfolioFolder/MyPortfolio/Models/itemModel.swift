//
//  ItemModel.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 03.07.23.
//

import Foundation

struct ItemModel: Identifiable, Codable {
    var id: String
    var titel: String
    var isCompleted: Bool

    init(id: String = UUID().uuidString, titel: String, isCompleted: Bool) {
        self.id = id
        self.titel = titel
        self.isCompleted = isCompleted
    }

    func updateCompletion() -> ItemModel {
        return ItemModel(id: id, titel: titel, isCompleted: !isCompleted)
    }
}
