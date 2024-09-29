import SwiftUI
import Foundation
import CoreImage.CIFilterBuiltins

//struct ListView: View {
//    @EnvironmentObject var viewModel: LinkViewModel
//    @State private var showQRCodeSheet = false
//    @State private var selectedItem: Link?
//    @Binding var filter : String
//    @Binding var isSearching: Bool
//
//
//    var body: some View {
//        Group {
//            if viewModel.isLoading {
//          //     ProgressView("Loading links...")
//            } else if viewModel.filteredLinks.isEmpty {
//         //    List{}
//            } else {
////                LinkListView(
////
////                    viewModel: viewModel,
////                    showQRCodeSheet: $showQRCodeSheet,
////                    selectedItem: $selectedItem,
////                    filterString: filter,
////                    isSearching: $isSearching
////                )
//            }
//        }
//        .onAppear {
//            if viewModel.links.isEmpty {
//                viewModel.fetchLinks()
//            }
//        }
//    }
//}
//
//struct EmptyStateView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "folder")
//                .font(.system(size: 50))
//                .padding(.bottom, 12)
//                .foregroundColor(.secondary)
//            Text("No URLs Found")
//                .font(.headline)
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//struct LinkListView: View {
//    @ObservedObject var viewModel: LinkViewModel
//    @Binding var showQRCodeSheet: Bool
//
//    @Binding var selectedItem: Link?
//    @Binding  var filterString: String
//    @Binding var isSearching: Bool
//
//
//
//
//    var body: some View {
//        List {
//            ForEach(viewModel.filteredLinks) { link in
//                LinkRow(
//                    link: link,
//                    showQRCodeSheet: $showQRCodeSheet,
//
//                    selectedItem: $selectedItem
//                )   .sheet(isPresented: $showQRCodeSheet) {
//
//                        QRCodeSheetView(viewModel: viewModel, link: link)
//
//                }
//            }
//            .onDelete(perform: { indexSet in
//                indexSet.forEach { index in
//                    let link = viewModel.filteredLinks[index]
//                    viewModel.deleteLink(id: link.id)
//                }
//            })
//            .onChange(of: filterString, initial: isSearching){
//
//            }
//        }
//
//    }
//}
//
//struct LinkRow: View {
//    let link: Link
//    @Binding var showQRCodeSheet: Bool
//
//    @Binding var selectedItem: Link?
//    @State private var isProcessing = false // State to handle button interaction
//
//    var body: some View {
//        HStack {
//            Text(link.url)
//                .font(.body)
//                .lineLimit(1)
//            Spacer()
//            Button(action: {
//
//            }) {
//                Image(systemName: "qrcode")
//                    .resizable()
//                    .frame(width: 24, height: 24)
//                    .padding()
//                    .background( Color.blue)
//                    .foregroundColor(.white)
//                    .clipShape(Circle())
//
//                    .shadow(radius: 5).onTapGesture {
//                        showQRCodeSheet = true
//
//                    }
//            }
//
//
//            Button(action: {
//
//            }) {
//                Image(systemName: "network")
//                    .resizable()
//                    .frame(width: 24, height: 24)
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .clipShape(Circle())
//                    .shadow(radius: 5).onTapGesture {
//                        if let url = URL(string: link.url) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
//            }
//        }
//    }
//}
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
struct QRCodeSheetView: View {
    @ObservedObject var viewModel: LinkViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var vm: AppViewModel
    let link: Link
    let context = CIContext()
    @State private var showShareSheet = false
    
    func generateQrImage(urlString: String) -> UIImage {
        let data = Data(urlString.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("QR Code for \(link.type.capitalized)")
                    .font(.headline)
                    .padding(.top)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(uiImage: generateQrImage(urlString: link.url))
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding()
                }
                .frame(width: 250, height: 250)
                
                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(title: "URL", value: link.url)
                    InfoRow(title: "Type", value: link.type.capitalized)
                   
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
                
                Button(action: {
                    showShareSheet = true
                }) {
                    Label("Share QR Code", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("QR Code", displayMode: .inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [generateQrImage(urlString: link.url)])
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct LinkListView: View {
    @EnvironmentObject private var viewModel: LinkViewModel
    @Binding var searchText: String
    
    var filteredLinks: [Link] {
        if searchText.isEmpty {
            return viewModel.links
        } else {
            return viewModel.links.filter { $0.url.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredLinks) { link in
                LinkRow(viewModel: viewModel,link: link)
            }
            .onDelete(perform: deleteLinks)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if filteredLinks.isEmpty {
                EmptyStateView()
            }
        }
        .onAppear {
            if viewModel.filteredLinks.isEmpty {
                viewModel.fetchLinks()
                print("fetching")
            }
        }
    }
    
    private func deleteLinks(at offsets: IndexSet) {
        offsets.forEach { index in
            let link = filteredLinks[index]
            viewModel.deleteLink(id: link.id)
        }
       
    }
}

struct LinkRow: View {
    @ObservedObject var viewModel: LinkViewModel
    @EnvironmentObject var vm: AppViewModel
    let link: Link
    @State private var showQRCodeSheet = false
    
    var body: some View {
       
            HStack {
                VStack(alignment: .leading, spacing: 4){
                    Text(link.url)
                                       .font(.headline)
                                       .lineLimit(1)
                                   Text(link.type)
                                       .font(.subheadline)
                                       .foregroundColor(.secondary)
                }
                
                Spacer()
                Button(action: {  }) {
                    Image(systemName: "qrcode").onTapGesture {
                        showQRCodeSheet = true
                    }
                }
                .buttonStyle(CircularButtonStyle(color: .blue))
                
                Button(action: {}) {
                    Image(systemName: "network").onTapGesture {
                        vm.openContent(link.url)
                    }
                }
                .buttonStyle(CircularButtonStyle(color: .green))
            }
            
            
        
        .sheet(isPresented: $showQRCodeSheet) {
            QRCodeSheetView(viewModel: viewModel, link: link)
        }
    }
    
   
}

struct CircularButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
                                .frame(width: 50, height: 50)
                                .background(color)
                                .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No URLs Found")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

