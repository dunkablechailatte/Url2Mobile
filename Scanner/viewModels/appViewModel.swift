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
enum scanType {
    
    case text
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
    
    @Published var savedItems: [RecognizedItem] = []
    @Published var textContenType: DataScannerViewController.TextContentType?
    @Published var hasAdded = true
    
    private let recentSavedItemsQueue = RecentValuesQueue<RecognizedItem>(maxSize: 1) // Limit to 1 item
   
   
    @Published var recognizedItems: [RecognizedItem] = [] {
           didSet {
               
               saveRecognizedItems(recognizedItems)
           }
       }
    
    // Function to save the recognized items (replace with your actual saving logic)
    func saveRecognizedItems(_ items: [RecognizedItem]) {
        savedItems.append(contentsOf: items)
        recentSavedItemsQueue.enqueue(savedItems.last!)
        savedItems = Array(savedItems.suffix(1))
       
       
        
        
        }
    
    func checkHasAdded(){
        hasAdded.toggle()
    }
      
   
  
    func clearSavedItems() {
            savedItems = []
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
    
    @Published var scanType: scanType = .text
    
    
    
    @Published var recognizesMultipleItems = false
    
   var recognizeDataType: DataScannerViewController.RecognizedDataType {
       .text(textContentType: .URL)
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
