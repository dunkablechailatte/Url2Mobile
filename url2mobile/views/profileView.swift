////
////  profileView.swift
////  url2mobile
////
////  Created by Hassan Ali on 09/09/2024.
////
//
//import Foundation
//import SwiftUI
//
//struct ProfileView: View {
//    @EnvironmentObject var authManager: AuthenticationManager
//    
//    var body: some View {
//        NavigationView {
//            if let profile = authManager.userProfile {
//                VStack(spacing: 20) {
//                    AsyncImage(url: profile.profilePictureURL) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    } placeholder: {
//                        ProgressView()
//                    }
//                    .frame(width: 150, height: 150)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
//                    
//                    Text(profile.name)
//                        .font(.title)
//                    
//                    Text(profile.email)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        authManager.signOut()
//                    }) {
//                        Text("Sign Out")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.red)
//                            .cornerRadius(10)
//                    }
//                }
//                .padding()
//                .navigationTitle("Profile")
//            } else {
//                Text("Loading profile...")
//            }
//        }
//    }
//}
//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//            .environmentObject(AuthenticationManager.shared)
//    }
//}
