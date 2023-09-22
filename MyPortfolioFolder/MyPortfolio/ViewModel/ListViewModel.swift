//
//  ListViewModel.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 03.07.23.
//

import Foundation

class ListViewModel: ObservableObject {
    @Published var items: [ItemModel] = [] {
        didSet {
            saveItem()
        }
    }

    let itemKey: String = "list_key"

    init() {
        getItems()
    }

    func getItems() {
        /*      let newItems = [
                  ItemModel(titel: "first elemen", isCompleted: true),
                  ItemModel(titel: "Organise an event", isCompleted: false),
                  ItemModel(titel: "Develop an App", isCompleted: false),
                  ItemModel(titel: "Go to sport", isCompleted: true),
              ]
              items.append(contentsOf: newItems)
         */
        guard
            let data = UserDefaults.standard.data(forKey: itemKey),
            let savedItems = try? JSONDecoder().decode([ItemModel].self, from: data)
        else { return }

        items.self = savedItems
    }

    func deleteItem(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }

    func moveItem(form: IndexSet, to: Int) {
        items.move(fromOffsets: form, toOffset: to)
    }

    func addItem(titel: String) {
        let newItem = ItemModel(titel: titel, isCompleted: false)
        items.append(newItem)
    }

    func updateItem(item: ItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item.updateCompletion()
        }
    }

    func saveItem() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.setValue(encodedData, forKey: itemKey)
        }
    }
}
