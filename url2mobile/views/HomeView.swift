
import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: LinkViewModel
    @EnvironmentObject var authService: AuthService
    @State private var createNewItem = false
    @State private var createNewUrl = false
    @State private var filter = ""
    @Environment(\.dismiss) var dismiss
    @State private var showAddLinkSheet = false
   
    @EnvironmentObject var vm: AppViewModel
    
    @State private var urlString: String = ""
    @State private var type: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
   
    @State private var searchText = ""
    @State private var isSearching = false
    
    var search: Bool {
        if !filter.isEmpty {
            isSearching.toggle()
            return true
        }
        else {
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                LinkListView(searchText: $searchText)
                    .searchable(text: $searchText, prompt: "Search links")
                    .onAppear(){
                        Task{
                            await vm.requestDataScannerAcess()
                        }
                    }
            }
            .navigationTitle("URL2Mobile")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading){
                    NavigationLink(destination: LoggedInView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showAddLinkSheet.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Button {
                        viewModel.fetchLinks()
                    } label: {
                        Image(systemName: "icloud.and.arrow.down")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                }
            }
            .sheet(isPresented: $showAddLinkSheet){
                AddLinkView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        createNewItem = true
                    } label: {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                            )
                    }.padding(.bottom, 20)
                }
            }
            
          
            .sheet(isPresented: $createNewItem) {
                ContentView()
            }
            .alert("Error", isPresented: $showError, actions: {
                Button("OK", role: .cancel) {
                    print("Error alert OK button tapped")
                }
            }, message: {
                Text(errorMessage)
            })
        }
        .onAppear {
            
        }
    }
}
struct AddLinkView: View {
    @EnvironmentObject var viewModel: LinkViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var url = ""
    @State private var type = "url"
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let linkTypes = ["URL", "email", "Phone"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Link Details")) {
                    TextField("Enter URL or Phone Number", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Picker("Type", selection: $type) {
                        ForEach(linkTypes, id: \.self) { linkType in
                            Text(linkType).tag(linkType.lowercased())
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: {addLink()
                        presentationMode.wrappedValue.dismiss()}) {
                        Text("Add Link")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(url.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(url.isEmpty)
                }
            }
            .navigationTitle("Add New Link")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func addLink() {
        viewModel.createLink(url: url, type: type) { result in
            switch result {
            case .success:
                alertMessage = "Link added successfully!"
                showAlert = true
                url = ""
                viewModel.fetchLinks()
                                
                                // Dismiss the view
                                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                alertMessage = "Failed to add link: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}




//import Foundation
//import SwiftUI
//
//struct HomeView: View {
//    @EnvironmentObject  var viewModel : LinkViewModel
//    @State private var createNewItem = false
//    @State private var createNewUrl = false
//    @State private var filter = ""
//    @Environment(\.dismiss) var dismiss
//    @State private var showAddLinkSheet = false
//   
//    @EnvironmentObject var vm: AppViewModel
//    
//    @State private var urlString: String = ""
//    @State private var type: String = ""
//    @State private var showError = false
//    @State private var errorMessage = ""
//   
//        @State private var searchText = ""
//     @State private var isSearching = false
//    
//    var search: Bool {
//        if !filter.isEmpty {
//            isSearching.toggle()
//            return true
//        }
//        else {
//            return false
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                LinkListView(searchText: $searchText)
//                               .navigationTitle("Links")
//                               .searchable(text: $searchText, prompt: "Search links").onAppear(){
//                    Task{
//                      await  vm.requestDataScannerAcess()
//                    }
//                }
//            }.navigationTitle("URL2Mobile")
//            .toolbar() {
//                ToolbarItemGroup(placement: .topBarTrailing) {
//                    Button {
//                        showAddLinkSheet.toggle()
//                    } label: {
//                        Image(systemName: "square.and.pencil")
//                        
//                            .resizable()
//                            .frame(width: 24, height: 24)
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddLinkSheet){
//                AddLinkView()
//            }
//            .toolbar {
//                ToolbarItemGroup(placement: .bottomBar) {
//                    Button {
//                     createNewItem = true
//                       
//                    } label: {
//                        Circle()
//                            .foregroundColor(.blue)
//                            .frame(width: 50, height: 50)
//                            .overlay(
//                                Image(systemName: "plus")
//                                    .foregroundColor(.white)
//                            )
//                    }.padding(.bottom, 20)
//                }
//            }
//          
//            .sheet(isPresented: $createNewItem) {
//                
//                ContentView()
//            }
//            .alert("Error", isPresented: $showError, actions: {
//                Button("OK", role: .cancel) {
//                    print("Error alert OK button tapped")
//                }
//            }, message: {
//                Text(errorMessage)
//            })
//        }.navigationTitle("URL2Mobile")
//        .onAppear {
//            print("HomeView appeared")
//        }
//    }
//}
//struct AddLinkView: View {
//    @EnvironmentObject  var viewModel : LinkViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var url = ""
//    @State private var type = "url"
//    
//    var body: some View {
//        VStack{
//            Form {
//                TextField("URL", text: $url)
//                Picker("Type", selection: $type) {
//                    Text("URL").tag("url")
//                    Text("WhatsApp").tag("whatsapp")
//                    Text("Phone").tag("phone")
//                }
//                .pickerStyle(SegmentedPickerStyle())
//            }
//            Spacer(minLength: 20)
//            Button("Add", action: {
//                viewModel.createLink(url: url, type: type) { result in
//                    switch result {
//                    case .success:
//                        presentationMode.wrappedValue.dismiss()
//                    case .failure(let error):
//                        print("Failed to create link: \(error)")
//                    }
//                }
//                
//            })
//            
//            .navigationTitle("Add New Link")
//            .navigationBarItems(trailing: Button("Cancel") {
//                 presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//}
