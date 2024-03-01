//
//  ScannerApp.swift
//  Scanner
//
//  Created by Hassan Ali on 01/03/2024.
//

import SwiftUI
import SwiftData
@main
struct ScannerApp: App {
   @StateObject private var vm = AppViewModel()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(vm)
                .task {
                   await vm.requestDataScannerAcess()
                }
        }.modelContainer(for: [item.self])
    }
    init(){
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
