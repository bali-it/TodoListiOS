//
//  AddItemView.swift
//  MyPortfolio.swift
//
//  Created by Basel Al Ali on 03.07.23.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var textIpt: String = ""
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State var alterTitel : String = ""
    @State var showAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                TextField("Add new ToDo ..", text: $textIpt)
                    .padding(.horizontal)
                    .frame(height: 55)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .accessibilityIdentifier("AddItemView.input")

                Button(action: savedButtonPressed, label: {
                    Text("save".uppercased())
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                })
                .accessibilityIdentifier("AddItemView.button")
            }
            .padding(14)
        }
        .navigationTitle("Add your ToDo..")
        .alert(isPresented: $showAlert, content: getAlert)
    }

    func savedButtonPressed() {
        if textIsAppropriate() {
            listViewModel.addItem(titel: textIpt)
            presentationMode.wrappedValue.dismiss()
        }
    }

    func textIsAppropriate() -> Bool {
        if textIpt.count < 3 {
            alterTitel = "⚠️ The length of the to-do item should be at least 3 characters"
            showAlert.toggle()
            return false
        }
        return true
    }

    func getAlert() -> Alert {
        return Alert(title: Text(alterTitel))
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
            .environmentObject(ListViewModel())
    }
}
