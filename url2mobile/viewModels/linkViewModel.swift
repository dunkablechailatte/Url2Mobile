//
////
////  appViewModel.swift
////  Scanner
////
////  Created by Hassan Ali on 01/03/2024.
////
//// 29 19
//import Foundation
//
//import SwiftUI
//import VisionKit
//import AVFoundation
//
//enum ScanType: String {
//    case  text
//}
//
//
//enum dataScannerAccessType{
//    case notDetermined
//    case cameraAccessNotGranted
//    case cameraNotAvailable
//    case scannerAvailable
//    case scannerNotAvailable
//}
//@MainActor
//final class AppViewModel : ObservableObject {
//    @Published var textContentType: DataScannerViewController.TextContentType?
//    @Published var savedItems: [RecognizedItem] = []
//    
//    @Published var hasAdded = true
//    
//    private let recentSavedItemsQueue = RecentValuesQueue<RecognizedItem>(maxSize: 1) // Limit to 1 item
//   
//   
//    @Published var recognizedItems: [RecognizedItem] = [] {
//           didSet {
//               
//               saveRecognizedItems(recognizedItems)
//           }
//       }
//    
//    // Function to save the recognized items (replace with your actual saving logic)
//    func saveRecognizedItems(_ items: [RecognizedItem]) {
//        savedItems.append(contentsOf: items)
//        recentSavedItemsQueue.enqueue(savedItems.last!)
//        savedItems = Array(savedItems.suffix(1))
//       
//       
//       
//        }
//    
//    func checkHasAdded(){
//        hasAdded.toggle()
//    }
//      
//   
//  
//    func clearSavedItems() {
//            savedItems = []
//        }
//    
//    
//
//    
//    func openURLInDefaultBrowser(_ urlString: String) {
//        guard let url = URL(string: urlString) else {
//            
//            
//            print("Invalid URL format: \(urlString)")
//            return
//        }
//        
//
//        // Check if the URL scheme is already specified (http:// or https://)
//        if url.scheme == "http" || url.scheme == "https" {
//            UIApplication.shared.open(url)
//            print("Invalid  format: \(urlString)")
//        } else {
//            // Add "https://" if no scheme is present
//            let modifiedURLString = "https://" + urlString
//            print(modifiedURLString)
//            guard let modifiedURL = URL(string: modifiedURLString) else {
//                print("Invalid URL format after adding scheme: \(modifiedURLString)")
//                return
//            }
//            UIApplication.shared.open(modifiedURL)
//        }
//    }
//    
//
//    
//    @Published var scanType: ScanType = .text
//      
//      
//      
//      @Published var recognizesMultipleItems = false
//      
//     var recognizeDataType: DataScannerViewController.RecognizedDataType {
//         .text(textContentType: textContentType)
//      }
//    
//   
//    
//    @Published var dataScannerAcsessStatus = dataScannerAccessType.notDetermined
//    private var isScannerAvailable : Bool {
//        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
//    }
//    func requestDataScannerAcess() async {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            dataScannerAcsessStatus = .cameraNotAvailable
//            return
//            
//        }
//        
//        switch AVCaptureDevice.authorizationStatus(for: .video){
//        case .authorized:
//            dataScannerAcsessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
//        case .restricted , .denied :
//            dataScannerAcsessStatus = .cameraAccessNotGranted
//        case .notDetermined:
//            let granted = await AVCaptureDevice.requestAccess(for: .video)
//            if granted {
//                dataScannerAcsessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
//            }else {
//                dataScannerAcsessStatus = .cameraAccessNotGranted
//            }
//        default: break
//        }
//        
//        
//    }
//    
//}
//class RecentValuesQueue<T> {
//  private var queue: [T] = []
//  private let maxSize: Int
//
//  init(maxSize: Int) {
//    self.maxSize = maxSize
//  }
//
//  func enqueue(_ item: T) {
//    queue.append(item)
//    if queue.count > maxSize {
//      queue.removeFirst()
//    }
//  }
//
//  var mostRecent: T? {
//    return queue.last
//  }
//}
//import Foundation
//import VisionKit
//import SwiftUI
//
//struct DataScannerView: UIViewControllerRepresentable {
//    @Binding var recognisedItem: [RecognizedItem]
//    
//    @EnvironmentObject var vm: AppViewModel
//    @State private var isScanning = true
//
//    func makeUIViewController(context: Context) -> DataScannerViewController {
//        // Define recognized data types including emails, phone numbers, and URLs
//        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
//            .text(textContentType: .URL),
//            .text(textContentType: .emailAddress),
//            .text(textContentType: .telephoneNumber),
//         
//        ]
//        
//        let vc = DataScannerViewController(
//            recognizedDataTypes: recognizedDataTypes,
//            qualityLevel: .fast,
//            recognizesMultipleItems: true,
//            isPinchToZoomEnabled: true,
//            isGuidanceEnabled: true,
//            isHighlightingEnabled: true
//        )
//        vc.delegate = context.coordinator
//        return vc
//    }
//    
//    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
//        if isScanning {
//            try? uiViewController.startScanning()
//        } else {
//            uiViewController.stopScanning()
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(recognisedItem: $recognisedItem, isScanning: $isScanning)
//    }
//    
//    class Coordinator: NSObject, DataScannerViewControllerDelegate {
//        @Binding var recognisedItem: [RecognizedItem]
//        @Binding var isScanning: Bool
//
//        init(recognisedItem: Binding<[RecognizedItem]>, isScanning: Binding<Bool>) {
//            self._recognisedItem = recognisedItem
//            self._isScanning = isScanning
//        }
//
//        // Called when an item is tapped
//        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//            switch item {
//            case .text(let text):
//                UIPasteboard.general.string = text.transcript
//                recognisedItem.append(item)
//                print("Tapped Item: \(text.transcript)")
//            default:
//                break
//            }
//            print(recognisedItem)
//        }
//
//        // Called when new items are added
//        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            recognisedItem.append(contentsOf: addedItems)
//            for item in addedItems {
//                switch item {
//                case .text(let text):
//                    print("Added Item: \(text.transcript) - Type: \(text.transcript ?? "unknown")")
//                default:
//                    break
//                }
//            }
//        }
//    }
//}
//
//import SwiftUI
//import VisionKit
//
//struct ContentView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject private var viewModel: LinkViewModel
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var vm: AppViewModel
//    
//    @State private var isPressed = false
//    
//    var isDisabled: Bool {
//        return getLatestTranscript().isEmpty
//    }
//    
//    func getLatestTranscript() -> String {
//        for item in vm.savedItems {
//            if case .text(let text) = item {
//                return text.transcript
//            }
//        }
//        return ""
//    }
//    
//  
//    private var mainView: some View {
//        DataScannerView(recognisedItem: $vm.recognizedItems)
//    }
//    
//    
//    
//    
//    var body: some View {
//        switch vm.dataScannerAcsessStatus {
//        case .scannerAvailable:
//            NavigationStack {
//                VStack {
//                    Spacer()
//                    VStack {
//                        Text("Tap on Url to select")
//                        
//                        
//                 
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                    }
//                    mainView
//                    Spacer()
//                    VStack {
//                      
//                        let latestTranscript = getLatestTranscript()
//                        let  category = categorizeString(latestTranscript)
//                        Text(latestTranscript.isEmpty ? "No URLs detected yet" : latestTranscript)
//                        
//                        Button {
//                            guard !latestTranscript.isEmpty, let url = URL(string: latestTranscript) else {
//                                print("Invalid URL or empty transcript")
//                                return
//                            }
//                            
//                            isPressed.toggle()
//                            withAnimation {
//                                isPressed.toggle()
//                            }
//                            
//                            vm.clearSavedItems()
//                            
//                            do {
//                                vm.checkHasAdded()
//                                print(vm.hasAdded)
//                                print(latestTranscript)
//                                
//                                viewModel.createLink(url: latestTranscript, type: category) { result in
//                                    switch result {
//                                    case .success:
//                                        presentationMode.wrappedValue.dismiss()
//                                    case .failure(let error):
//                                        print("Failed to create link: \(error)")
//                                    }
//                                }
//                                
//                            } catch {
//                                print("Error saving item: \(error.localizedDescription)")
//                            }
//                            
//                            dismiss()
//                            
//                        } label: {
//                            ZStack {
//                                Circle()
//                                    .stroke(lineWidth: 6)
//                                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : .red)
//                                    .frame(width: 65, height: 65)
//                                
//                                Circle()
//                                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : .red)
//                                    .frame(width: isPressed ? 32 : 55)
//                                    .scaleEffect(isPressed ? 0.9 : 1.0)
//                                    .animation(.easeOut, value: 0.3)
//                            }
//                        }
//                        .disabled(isDisabled)
//                    }
//                }
//            }
//            
//        case .cameraNotAvailable:
//            Text("Your device does not have a camera")
//            
//        case .scannerNotAvailable:
//            Button("Scanner Not Supported") {
//                // Handle the unsupported scanner case
//            }
//            
//        case .cameraAccessNotGranted:
//            Text("Please provide access to the camera in settings")
//            
//        case .notDetermined:
//            Text("Requesting camera access")
//        }
//    }
// 
//
//    enum StringCategory {
//        case whatsapp
//        case phone
//        case email
//        case url
//        case unknown
//    }
//
//    func categorizeString(_ input: String) -> String {
//          // WhatsApp-related patterns
//          let whatsappPatterns = [
//              "\\bwhatsapp\\b",
//              "\\bwa\\b",
//              "\\+\\d{1,3}\\s?\\d{10,14}"  // International phone number format often used for WhatsApp
//          ]
//          
//          // Phone number pattern
//          let phonePattern = "\\b(\\+\\d{1,3}\\s?)?\\d{10,14}\\b"
//          
//          // Email pattern
//          let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//          
//          // URL pattern
//          let urlPattern = "(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
//          
//          // Check for WhatsApp-related patterns
//          for pattern in whatsappPatterns {
//              if let _ = input.range(of: pattern, options: .regularExpression) {
//                  return "whatsapp"
//              }
//          }
//          
//          // Check for phone number
//          if let _ = input.range(of: phonePattern, options: .regularExpression) {
//              return "phone"
//          }
//          
//          // Check for email
//          if let _ = input.range(of: emailPattern, options: .regularExpression) {
//              return "email"
//          }
//          
//          // Check for URL
//          if let _ = input.range(of: urlPattern, options: .regularExpression) {
//              return "url"
//          }
//          
//          // If no match found
//          return "unknown"
//      }
//
//}
//
