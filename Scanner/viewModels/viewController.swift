//
//  viewController.swift
//  Scanner
//
//  Created by Hassan Ali on 01/03/2024.
//
import Foundation
import VisionKit
import SwiftUI

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognisedItem: [RecognizedItem]
    
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    @EnvironmentObject var vm: AppViewModel
    @State private var isScanning = true
    
    
func makeUIViewController(context: Context) -> some DataScannerViewController {
        let vc = DataScannerViewController(recognizedDataTypes: [recognizedDataType],
        qualityLevel: .balanced,
        recognizesMultipleItems: false,
        isPinchToZoomEnabled: true,
        isGuidanceEnabled: false,
        isHighlightingEnabled: true)
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.delegate = context.coordinator
        if isScanning {
            try? uiViewController.startScanning()
        }else {
            uiViewController.stopScanning()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(recognisedItem: $recognisedItem,   isScanning: $isScanning)
    }
    @MainActor static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    class Coordinator: NSObject, DataScannerViewControllerDelegate{
        @Binding var recognisedItem: [RecognizedItem]
        @Binding var isScanning: Bool
        
        init(recognisedItem: Binding<[RecognizedItem]>, isScanning: Binding<Bool>) {
            self._recognisedItem = recognisedItem
           self._isScanning = isScanning
        }
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text): UIPasteboard.general.string = text.transcript
                recognisedItem.append(item)
            default: ""
            }
            print(recognisedItem)
        }
        /*
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognisedItem.append(contentsOf: addedItems)
            
        }
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognisedItem = recognisedItem.filter {
                item in !removedItems.contains(where: {$0.id == item.id})
            }
        }
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            
        }
         */
    }
}
