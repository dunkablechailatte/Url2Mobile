//
//  ContentView.swift
//  Scanner
//
//  Created by Hassan Ali on 01/03/2024.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    
     var isDisabled : Bool {
        if getLatestTranscript()!.isEmpty  {
            return true
        }else {
            return false
        }
    }
    
    @State private var isPressed = false
    func getLatestTranscript() -> String?  {
    var urlString: String? = ""
       for item in vm.savedItems {
        if case .text(let text) = item {
          urlString = text.transcript
            break
        }
      }
        return urlString
    }
   
    private var mainView: some View {
        DataScannerView(recognisedItem: $vm.recognizedItems, recognizedDataType: vm.recognizeDataType)
    }
    
    var body: some View {
        switch vm.dataScannerAcsessStatus{
        case .scannerAvailable:
            NavigationStack {
                VStack{
                    Spacer()
                    VStack{
                        Text("Tap on Url to select")
                    }
                    mainView
                    Spacer()
                    VStack{
                        if let  latestTranscript = !vm.savedItems.isEmpty ? getLatestTranscript() : "No URLs detected yet"{
                             Text("\(latestTranscript)")
                           }
                        Button{
                            if  !getLatestTranscript()!.isEmpty {
                                let newItem = item(url: getLatestTranscript() ?? "ww.origen.pk")
                                isPressed.toggle()
                                      withAnimation {
                                        isPressed.toggle()
                                      }
                                    context.insert(newItem)
                                vm.clearSavedItems()

                                do {
                                  try context.save()
//                                  print("Item saved successfully")
                                    vm.checkHasAdded()
                                    print(vm.hasAdded)
                                    print(getLatestTranscript())
                                } catch {
                                  print("Error saving item: \(error.localizedDescription)")
                                }
                               }
                            dismiss()
                        }label: {
                            ZStack{
                                Circle()
                                        .stroke(lineWidth: 6)
                                        .foregroundColor(isDisabled ? .gray.opacity(0.5) : .red)
                                        .frame(width: 65, height: 65)
                                
                                Circle()
                                       .foregroundColor(isDisabled ? .gray.opacity(0.5) : .red)
                                       .frame(width: isPressed ? 32 : 55)
                                       .scaleEffect(isPressed ? 0.9 : 1.0)
                                       .animation(.easeOut, value: 0.3)
                            }
                        }.disabled(isDisabled)
                    }
                }
            }
            
        case .cameraNotAvailable: Text("Your device does not have a camera")
        case .scannerNotAvailable: Button("Hey"){
            let newItem = item(url: "www.origen.pk")
            context.insert(newItem)
        }
        case .cameraAccessNotGranted: Text("Please provide access to the camera in setting")
        case .notDetermined: Text("Requesting camera Access")
        }
    }
}


    




   


