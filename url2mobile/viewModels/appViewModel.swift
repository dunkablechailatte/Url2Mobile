//
//  appViewModel.swift
//  Scanner
//
//  Created by Hassan Ali on 01/03/2024.
//
// 29 19
import Foundation

import SwiftUI
import VisionKit
import AVFoundation

enum ScanType: String {
    case  text
}


enum dataScannerAccessType{
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}
@MainActor
final class AppViewModel : ObservableObject {
    @Published var textContentType: DataScannerViewController.TextContentType? = .URL
    @Published var savedItems: [RecognizedItem] = []
    @Published var recognizesMultipleItems = false
    @Published var hasAdded = true
    
    
    private let recentSavedItemsQueue = RecentValuesQueue<RecognizedItem>(maxSize: 1) // Limit to 1 item
   
    
    
    
    @Published var authToken: String = "" // Store the token here
        
       
    
    
    
    
    
    
    
    
    
    
    private var contentType: String {
        if textContentType == .URL {
            return "url"
        }else if textContentType == .telephoneNumber {
            return "Phone Number"}
        else if textContentType == .emailAddress{
            return "Email"
        }
        else {
            return "Text"
        }
    }
    
    
    
    
   
    @Published var recognizedItems: [RecognizedItem] = [] {
           didSet {
               
               saveRecognizedItems(recognizedItems)
           }
       }
    
    
    @Published var scanType: ScanType = .text
      
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        .text(textContentType: textContentType)
     }
      
    
    var headerText: String {
            if recognizedItems.isEmpty {
                return "Scanning \(contentType)"
            } else {
                return "Recognized \(recognizedItems.count) item(s)"
            }
        }
        
          var dataScannerViewId: Int {
            var hasher = Hasher()
            hasher.combine(scanType)
            hasher.combine(recognizesMultipleItems)
            if let textContentType {
                hasher.combine(textContentType)
            }
            return hasher.finalize()
        }
    
    
    

    
     
      
     var recognizeDataType: DataScannerViewController.RecognizedDataType {
         .text(textContentType: textContentType)
      }
    // Function to save the recognized items (replace with your actual saving logic)
    func saveRecognizedItems(_ items: [RecognizedItem]) {
        savedItems.append(contentsOf: items)
        recentSavedItemsQueue.enqueue(savedItems.last!)
        savedItems = Array(savedItems.suffix(1))
       
       
        var dataScannerViewId: Int {
               var hasher = Hasher()
               hasher.combine(scanType)
               hasher.combine(recognizesMultipleItems)
               if let textContentType {
                   hasher.combine(textContentType)
               }
               return hasher.finalize()
           }
        
        }
    
    func checkHasAdded(){
        hasAdded.toggle()
    }
      
   
  
    func clearSavedItems() {
            savedItems = []
        }
    
    
    func openContent(_ content: String) {
        // URL
        if let url = URL(string: content) {
            openURLInDefaultBrowser(content)
        }
        
        // Phone number
        let phoneNumberSet = CharacterSet(charactersIn: "+0123456789")
        if content.rangeOfCharacter(from: phoneNumberSet.inverted) == nil {
            if let phoneURL = URL(string: "tel://\(content)") {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            }
            return
        }
        
        // Email
        if content.contains("@") {
            if let emailURL = URL(string: "mailto:\(content)") {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            }
            return
        }
        
        // WhatsApp
        if content.lowercased().contains("whatsapp") {
            if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(content)") {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
            return
        }
        
        // If none of the above conditions are met
        print("Unable to open content: \(content)")
    }
    
    func openURLInDefaultBrowser(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            
            
            print("Invalid URL format: \(urlString)")
            return
        }
        

        // Check if the URL scheme is already specified (http:// or https://)
        if url.scheme == "http" || url.scheme == "https" {
            UIApplication.shared.open(url)
            print("Invalid  format: \(urlString)")
        } else {
            // Add "https://" if no scheme is present
            let modifiedURLString = "https://" + urlString
            print(modifiedURLString)
            guard let modifiedURL = URL(string: modifiedURLString) else {
                print("Invalid URL format after adding scheme: \(modifiedURLString)")
                return
            }
            UIApplication.shared.open(modifiedURL)
        }
    }
    

    
    
    
   
    
    @Published var dataScannerAcsessStatus = dataScannerAccessType.notDetermined
    private var isScannerAvailable : Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    func requestDataScannerAcess() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAcsessStatus = .cameraNotAvailable
            return
            
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            dataScannerAcsessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
        case .restricted , .denied :
            dataScannerAcsessStatus = .cameraAccessNotGranted
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAcsessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            }else {
                dataScannerAcsessStatus = .cameraAccessNotGranted
            }
        default: break
        }
        
        
    }
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "tokenKey")
    }
}
class RecentValuesQueue<T> {
  private var queue: [T] = []
  private let maxSize: Int

  init(maxSize: Int) {
    self.maxSize = maxSize
  }

  func enqueue(_ item: T) {
    queue.append(item)
    if queue.count > maxSize {
      queue.removeFirst()
    }
  }

  var mostRecent: T? {
    return queue.last
  }
}
