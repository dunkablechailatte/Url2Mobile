import Foundation
import VisionKit
import SwiftUI

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognisedItem: [RecognizedItem]
    
    @EnvironmentObject var vm: AppViewModel
    @State private var isScanning = true
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    func makeUIViewController(context: Context) -> DataScannerViewController {
       
        
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .fast,
            recognizesMultipleItems: recognizesMultipleItems,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognisedItem: $recognisedItem, isScanning: $isScanning)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognisedItem: [RecognizedItem]
        @Binding var isScanning: Bool

        init(recognisedItem: Binding<[RecognizedItem]>, isScanning: Binding<Bool>) {
            self._recognisedItem = recognisedItem
            self._isScanning = isScanning
        }

        // Called when an item is tapped
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                UIPasteboard.general.string = text.transcript
                recognisedItem.append(item)
                print("Tapped Item: \(text.transcript)")
            default:
                break
            }
            print(recognisedItem)
        }

        // Called when new items are added
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    recognisedItem.append(contentsOf: addedItems)
                    
                }
    }
}

