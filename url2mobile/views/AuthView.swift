
import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack {
                Image("AppIcon") // Assuming you have an AppIcon image in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 10)
                
                Text("url2mobile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 50)
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn(duration: 1.2), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.7))
            )
        }
    }
}

struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                LoadingView()
            }
        }
    }
}

extension View {
    func loading(_ isLoading: Bool) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading))
    }
}
