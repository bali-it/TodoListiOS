//
//  StartView.swift
//  CV
//
//  Created by Basel Al Ali on 11.04.23.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var listViewModel: ListViewModel

    var body: some View {
        NavigationView {
            ZStack {
                if listViewModel.items.isEmpty {
                    NoitemsView()
                        .transition(AnyTransition.opacity.animation(.easeIn))
                } else {
                    List {
                        ForEach(listViewModel.items) { item in
                            ListRowView(item: item)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        listViewModel.updateItem(item: item)
                                    }
                                }
                        }
                        .onDelete(perform: listViewModel.deleteItem)
                        .onMove(perform: listViewModel.moveItem)
                    }
                    .buttonStyle(.borderedProminent)
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My List 🏞️..")
            .navigationBarItems(
                leading: EditButton(),
                trailing:
                NavigationLink("Add", destination: AddItemView())
            )
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StartView()
        }
        .environmentObject(ListViewModel())
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
