//
//  AddNewLinkView.swift
//  Scanner
//
//  Created by Hassan Ali on 07/03/2024.
//

import SwiftUI

struct AddNewLinkView: View {
    @Environment(\.dismiss) var  dismiss
    @Environment(\.modelContext) private var context
    @State private  var urlString : String = ""
    var body: some View {
        NavigationStack{
            Form{
                TextField("URL" , text: $urlString)
                Button("Create") {
                    let newItem = item(url: urlString.lowercased())
                    context.insert(newItem)
                    dismiss()
                }.frame(maxWidth: .infinity, alignment: .trailing)
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                    .disabled(urlString.isEmpty)
                    .navigationTitle("New Url")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

