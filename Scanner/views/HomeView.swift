//
//  HomeView.swift
//  Scanner
//
//  Created by Hassan Ali on 01/03/2024.
//

import SwiftUI
import SwiftData
import CoreImage.CIFilterBuiltins

struct HomeView: View {
    @State private var createNewItem = false
    @State private var createNewUrl = false
    @State private var filter = ""
    @Environment(\.dismiss) var  dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var vm: AppViewModel
    @State private  var urlString : String = ""
    var body: some View {
        NavigationStack {
          
                VStack{
                  
                        
                        ListView(filterString : filter).searchable(text: $filter , prompt: "Search your List")
                    
                    
                }.navigationTitle("URL2Mobile")
        
           
            .toolbar(){
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button{
                        createNewUrl.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar){
                    Button {
                       
                      createNewItem = true
                    } label: {
                        Circle()
                            .foregroundColor(.blue) // Set your desired color
                            .frame(width: 50, height: 50)
                            .overlay(
                              Image(systemName: "plus")
                                .foregroundColor(.white) // Set your desired text color
                            )
                    }.padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $createNewItem) {
              ContentView()
            }
            .alert("Add Url", isPresented: $createNewUrl, actions: {
                TextField("Enter " , text: $urlString)
                Button("Create") {
                    let newItem = item(url: urlString.lowercased())
                    context.insert(newItem)
                    dismiss()
                    urlString = ""
                }
.disabled(urlString.isEmpty)
                
                Button("Cancel") {
                       dismiss()  // Dismiss the alert when "Cancel" is clicked
                   }
            })
            //.sheet(isPresented: $createNewUrl){
              //  AddNewLinkView()
                //    .presentationDetents([.medium])
          //  }
            
        }.navigationTitle("URL2MObile")
    }
    
}



   
