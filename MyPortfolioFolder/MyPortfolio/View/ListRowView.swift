//
//  ListRowView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 03.07.23.
//

import SwiftUI

struct ListRowView: View {
    let item: ItemModel

    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ?
                "checkmark.circle" :
                "circle")
                .foregroundColor(item.isCompleted ? .green : .red)

            Text(item.titel)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var item1 = ItemModel(titel: "Write an script", isCompleted: false)
    static var item2 = ItemModel(titel: "Visit a Family", isCompleted: true)
    static var item3 = ItemModel(titel: "Visit a Family", isCompleted: true)
    static var item4 = ItemModel(titel: "Go to shool", isCompleted: false)

    static var previews: some View {
        Group {
            ListRowView(item: item1)
            ListRowView(item: item2)
            ListRowView(item: item3)
            ListRowView(item: item4)
        }
        .previewLayout(.sizeThatFits)
    }
}
