//
//  ListView.swift
//  Scanner
//
//  Created by Hassan Ali on 07/03/2024.
//

import SwiftUI
import SwiftData
import CoreImage.CIFilterBuiltins
struct ListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
   
    @State private var selectedItem: item?
    @State private var showQRCodeSheet = false
    @State private var hasShownAlertThisVisit = false
      @State private var showConfirmation = false
   
    
    @Query private var itemsList: [item]
    
    
    init(filterString: String){
        let predicate = #Predicate<item> {
            sitem in sitem.url.localizedStandardContains(filterString) || filterString.isEmpty
        }
        _itemsList = Query(filter: predicate, sort: \item.date ,  order: .reverse)
    }
      
     

      @State private var renderedImage: Image?
     
     
     
    
     
     
    
    @EnvironmentObject var vm: AppViewModel
    
   
    var body: some View {
        Group {
            if itemsList.isEmpty {
                ZStack{
                    List{}
                    HStack(alignment: .center){
                        VStack{
                            Image(systemName: "folder").padding(.bottom , 12).foregroundStyle(.secondary)
                            Text("No Urls Found").foregroundStyle(.secondary)
                           
                                
                        }
                        
                    }
                }
                    
               
                
            }else {
                List {
                  ForEach(itemsList) { item in
                    HStack {
                      Text(item.url).font(.body)
                            .lineLimit(1) // Limit the number of lines displayed
                          
                      Spacer()
                      Button(action: {
                          
                          
                        if !hasShownAlertThisVisit { // Check if alert shown this visit
                          selectedItem = item
                          showConfirmation = true
                          hasShownAlertThisVisit = true // Set flag for this visit
                        }else{
                            showQRCodeSheet = true
                            selectedItem = item
                        }
                          
                          
                      }) {
                        Image(systemName: "square.and.arrow.up")
                          .resizable()
                          .frame(width: 20, height: 24)
                          .padding(10)
                      }
                        Button(action: {}){
                            Image(systemName: "network") .resizable()
                                .frame(width: 20, height: 20)
                                .padding(10)
                        }.onTapGesture {
                            vm.openURLInDefaultBrowser(item.url)
                        }
                    }
                  }
                  .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                      let itemList = itemsList[index]
                      context.delete(itemList)
                    }
                  })
                }

                
                .navigationTitle("URL2Mobile")
                
               
            
                
                .sheet(isPresented: $showQRCodeSheet) {
                  if let item = selectedItem {
                      VStack {
                          let renderer = ImageRenderer(content: sheetView(sItem: item)).uiImage
                          
                          
                          
                          sheetView(sItem: item).padding(.horizontal)
                          Spacer()
                          
                          ShareLink("Share QR Code",
                                            item: Image(uiImage: renderer ?? UIImage()),
                                            subject: Text("Share QR Code for \(item.url)"),
                                            message: Text("Share QR Code for \(item.url)"),
                                            preview:
                                              SharePreview(item.url, image: Image(uiImage: renderer ?? UIImage()))
                                             
                                       ) .buttonStyle(.borderedProminent)
                                         .tint(.blue)
                                         .foregroundColor(.white)
                                         .font(.system(size: 18, weight: .semibold))
                                         .frame(maxWidth: .infinity)
                                         .cornerRadius(10)
                                         .padding(.vertical)
                                         
                          
                          Spacer()

                          
                          
                        
                          
                          
                          
                      }.presentationDetents([.medium])
                        
                        
                             
                          
                  }
                          
                }
                  }
                }
                .alert(isPresented: $showConfirmation) {
                  Alert(
                    title: Text("Generate QR Code"),
                    message: Text("Do you want to generate a QR code for this item?"),
                    primaryButton: .default(Text("Generate")) {
                      showQRCodeSheet = true // Generate and display QR code only on confirmation
                    },
                    secondaryButton: .cancel()
                  )
                
                
                
                
                
                
                
                
                
                
                
                
                
            }
        }
    
   
    
    struct sheetView: View {
      let sItem: item
        let Context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        func generateQrImage(urlString: String) -> UIImage {
            filter.message = Data(urlString.utf8)
            if let outputImage = filter.outputImage {
                if let cgImage = Context.createCGImage(outputImage, from: outputImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
      var body: some View {
    
       

          VStack {
            Text(sItem.url)
              .font(.title)
              .padding(.top)

            ZStack {
              RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5) // Optional shadow effect

              Image(uiImage: generateQrImage(urlString: sItem.url) ?? UIImage())
                .interpolation(.none)
                .resizable()
                .frame(width: 200, height: 200)
                .padding()
            }

            Spacer()

           
            
          }
      
      }
    }

    
    
    
    
    }



