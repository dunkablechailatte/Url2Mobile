//
//  url2mobileApp.swift
//  url2mobile
//
//  Created by Hassan Ali on 10/08/2024.
//

import SwiftUI

@main
struct url2mobileApp: App {
    @StateObject private var auth = AuthService.shared
    @StateObject private var vm = AppViewModel()
    @StateObject private var viewModel = LinkViewModel()
     
     var body: some Scene {
         WindowGroup {
          
            //HomeView()
               //  AuthView()
           LaunchView()
                        .environmentObject(vm)
                        .environmentObject(viewModel)
                        .environmentObject(auth)
                        
                }
             
     }
     init(){
         print(URL.applicationSupportDirectory.path(percentEncoded: false))
     }
}

