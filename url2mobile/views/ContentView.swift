import SwiftUI
import VisionKit

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var viewModel: LinkViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    
    @State private var isPressed = false
    
    var isDisabled: Bool {
        return getLatestTranscript().isEmpty
    }
    
    func getLatestTranscript() -> String {
        for item in vm.savedItems {
            if case .text(let text) = item {
                return text.transcript
            }
        }
        return ""
    }
    
    func clean(){
        getLatestTranscript()
        
    }
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
          
            ("URL", .URL),
            ("Phone", .telephoneNumber),
            ("Email", .emailAddress),
            ("All", .none),
        ]
  
    private var mainView: some View {
        DataScannerView(recognisedItem: $vm.recognizedItems, recognizedDataType: vm.recognizedDataType, recognizesMultipleItems: vm.recognizesMultipleItems).id(vm.dataScannerViewId)
    }
    
    
    
    
    var body: some View {
        switch vm.dataScannerAcsessStatus {
        case .scannerAvailable:
            NavigationStack {
                VStack {
                    Spacer()
                    VStack {
                        Text("Tap on an item to select")
                        
                        
                 
                        headerView
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    }
                    mainView
                    Spacer()
                    VStack {
                      
                        let latestTranscript = getLatestTranscript()
                        let  category = categorizeString(latestTranscript)
                        Text(latestTranscript.isEmpty ? "No URLs detected yet" : latestTranscript)
                        
                        Button {
                            guard !latestTranscript.isEmpty, let url = URL(string: latestTranscript) else {
                                print("Invalid URL or empty transcript")
                                return
                            }
                            
                            isPressed.toggle()
                            withAnimation {
                                isPressed.toggle()
                            }
                            
                            vm.clearSavedItems()
                            
                            do {
                                vm.checkHasAdded()
                                print(vm.hasAdded)
                                print(latestTranscript)
                                
                                viewModel.createLink(url: latestTranscript, type: category) { result in
                                    switch result {
                                    case .success:
                                        print("creating link with: \(latestTranscript) of type \(category)")
                                       viewModel.fetchLinks()
                                        presentationMode.wrappedValue.dismiss()
                                    case .failure(let error):
                                        print("Failed to create link: \(error)")
                                    }
                                }
                                
                            } catch {
                                print("Error saving item: \(error.localizedDescription)")
                            }
                            vm.clearSavedItems()
                            dismiss()
                            
                        } label: {
                            ZStack {
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
                        }
                        .disabled(isDisabled)
                    }
                }
            }
            
        case .cameraNotAvailable:
            Text("Your device does not have a camera")
            
        case .scannerNotAvailable:
            Button("Scanner Not Supported") {
                // Handle the unsupported scanner case
            }
            
        case .cameraAccessNotGranted:
            Text("Please provide access to the camera in settings")
            
        case .notDetermined:
            Text("Requesting camera access")
        }
    }
 

    enum StringCategory {
        case whatsapp
        case phone
        case email
        case url
        case unknown
    }

    func categorizeString(_ input: String) -> String {
          // WhatsApp-related patterns
        let whatsappPatterns = [
                    // WhatsApp web links
                    "https?://(?:www\\.)?wa\\.me/\\S+",
                    "https?://(?:www\\.)?whatsapp\\.com/\\S+",
                    // WhatsApp invite links
                    "https?://chat\\.whatsapp\\.com/\\S+",
                    // Text patterns indicating WhatsApp contact or group
                    "(?i)\\bwhatsapp(?:\\s+group|\\s+chat)?\\s+link\\b",
                    "(?i)\\bjoin\\s+(?:my|our)\\s+whatsapp\\b"
                ]
                  

        let phonePattern = "\\+?\\d{1,4}\\s?(?:\\(\\d{1,4}\\))?[\\s.-]?\\d{1,4}[\\s.-]?\\d{1,9}"
          
          // Email pattern
          let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
          
          // URL pattern
          let urlPattern = "(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
          
          // Check for WhatsApp-related patterns
        for pattern in whatsappPatterns {
                    if let _ = input.range(of: pattern, options: .regularExpression) {
                        return "whatsapp"
                    }
                }
          
          // Check for phone number
          if let _ = input.range(of: phonePattern, options: .regularExpression) {
              return "phone"
          }
          
          // Check for email
          if let _ = input.range(of: emailPattern, options: .regularExpression) {
              return "email"
          }
          
          // Check for URL
          if let _ = input.range(of: urlPattern, options: .regularExpression) {
              return "url"
          }
          
          // If no match found
          return "unknown"
      }

    private var headerView: some View {
    
            VStack {
                HStack {
                   
                    
                    Picker("Scan Type", selection: $vm.scanType) {
                        
                        Text("Text").tag(ScanType.text).onTapGesture {
                            print(vm.scanType)
                        }
                    }.pickerStyle(.segmented)
                    
                    Toggle("Scan multiple", isOn: $vm.recognizesMultipleItems)
                }.padding(.top)
                
                if vm.scanType == .text {
                    Picker("Text content type", selection: $vm.textContentType) {
                        ForEach(textContentTypes, id: \.self.textContentType) { option in
                            Text(option.title).tag(option.textContentType)
                        }
                    }.pickerStyle(.segmented)
                        .onChange(of: vm.textContentType, perform: { value in
                            vm.clearSavedItems()
                        })
                }
                
               
            }.padding(.horizontal)
        }
}

