import SwiftUI
import Foundation

struct LaunchView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var vm: LinkViewModel
    @State private var isChecking = true
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            Group {
                if isChecking {
                    launchScreen
                } else if authService.isAuthenticated {
                    HomeView().onAppear(
                        
                    )
                } else if isRegistering {
                    SignUpView(isRegistering: $isRegistering)
                } else {
                    LoginView(isRegistering: $isRegistering)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isChecking = false
            }
        }
    }
    
    private var launchScreen: some View {
        ZStack {
            Color("LaunchBackground")
                .ignoresSafeArea()
            
            VStack {
                Image("1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .padding()
                
                Text("url2mobile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var vm: LinkViewModel
    @EnvironmentObject var authService: AuthService
    @Binding var isRegistering: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack(alignment: .center) {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Text("Welcome Back")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 20) {
                        CustomTextField(text: $email, placeholder: "Email", icon: "envelope")
                            .onChange(of: email) { _ in
                                isEmailValid = isValidEmail(email)
                                errorMessage = nil
                            }
                        if !isEmailValid {
                            Text("Please enter a valid email")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        CustomSecureField(text: $password, placeholder: "Password", icon: "lock")
                            .onChange(of: password) { _ in
                                isPasswordValid = password.count >= 6
                                errorMessage = nil
                            }
                        if !isPasswordValid {
                            Text("Password must be at least 6 characters")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        if isValidEmail(email) && isPasswordValid {
                            isLoading = true
                            authService.login(email: email, password: password) { success, error in
                                isLoading = false
                                vm.fetchLinks()
                                if !success {
                                    errorMessage = error ?? "An error occurred"
                                }
                            }
                        }
                        
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .disabled(!isEmailValid || !isPasswordValid || isLoading)
                    .opacity((!isEmailValid || !isPasswordValid || isLoading) ? 0.6 : 1)
                    
                    Button("Don't have an account? Sign Up") {
                        isRegistering = true
                    }
                    .foregroundColor(.blue)
                    .padding(.top)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            
            if isLoading {
                LoadingView()
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct SignUpView: View {
    @EnvironmentObject var vm: LinkViewModel
    @EnvironmentObject var authService: AuthService
    @Binding var isRegistering: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isNameValid = true
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Text("Create Account")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 20) {
                        CustomTextField(text: $name, placeholder: "Name", icon: "person")
                            .onChange(of: name) { _ in
                                isNameValid = !name.isEmpty
                                errorMessage = nil
                            }
                        if !isNameValid {
                            Text("Name is required")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        CustomTextField(text: $email, placeholder: "Email", icon: "envelope")
                            .onChange(of: email) { _ in
                                isEmailValid = isValidEmail(email)
                                errorMessage = nil
                            }
                        if !isEmailValid {
                            Text("Please enter a valid email")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        CustomSecureField(text: $password, placeholder: "Password", icon: "lock")
                            .onChange(of: password) { _ in
                                isPasswordValid = password.count >= 8
                                errorMessage = nil
                            }
                        if !isPasswordValid {
                            Text("Password must be at least 6 characters")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        if isNameValid && isValidEmail(email) && isPasswordValid {
                            isLoading = true
                            authService.register(name: name, email: email, password: password) { success, error in
                                isLoading = false
                                vm.fetchLinks()
                                if !success {
                                    errorMessage = error ?? "An error occurred"
                                }
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.green)
                            )
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .disabled(!isNameValid || !isEmailValid || !isPasswordValid || isLoading)
                    .opacity((!isNameValid || !isEmailValid || !isPasswordValid || isLoading) ? 0.6 : 1)
                    
                    Button("Already have an account? Login") {
                        isRegistering = false
                    }
                    .foregroundColor(.blue)
                    .padding(.top)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            
            if isLoading {
                LoadingView()
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// ... (CustomTextField, CustomSecureField, and LoggedInView remain unchanged)

//struct LoadingView: View {
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4)
//                .ignoresSafeArea()
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                .scaleEffect(1.5)
//        }
//    }
//}



struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("TextFieldBackground"))
        )
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("TextFieldBackground"))
        )
    }
}

struct loadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

struct LoggedInView: View {
    @EnvironmentObject private var viewModel: LinkViewModel
    @State private var isLoading = false
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                LoadingView()
            }
            Text("Welcome, \(authService.currentUser?.name ?? "User")!")
                .font(.title)
            
            Button(action: {
                isLoading = true
                print(isLoading)
                Task{
                   authService.logout()
                    isLoading = false
                    print(isLoading)
                    viewModel.links = []
                    viewModel.filteredLinks = []
                    
                }
                
            }) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red)
                    )
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding()
        }
       
       
    }
   
}
import SwiftUI

//struct AuthView: View {
//    @EnvironmentObject var authService: AuthService
//    
//    @State private var isRegistering = false
//    
//    var body: some View {
//        NavigationView {
//            if authService.isAuthenticated {
//                HomeView().onAppear(
//                )
//                   
//            } else {
//                if isRegistering {
//                    SignUpView(isRegistering: $isRegistering)
//                        .environmentObject(authService)
//                } else {
//                    LoginView(isRegistering: $isRegistering)
//                        .environmentObject(authService)
//                }
//            }
//        }
//    }
//}
//
//struct LoginView: View {
//    @EnvironmentObject var authService: AuthService
//    @Binding var isRegistering: Bool
//    @State private var email = ""
//    @State private var password = ""
//    @State private var isEmailValid = true
//    @State private var isPasswordValid = true
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Welcome Back")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            
//            VStack(alignment: .leading, spacing: 10) {
//                TextField("Email", text: $email)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .autocapitalization(.none)
//                    .onChange(of: email) { _ in
//                        isEmailValid = isValidEmail(email)
//                    }
//                if !isEmailValid {
//                    Text("Please enter a valid email")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 10) {
//                SecureField("Password", text: $password)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .onChange(of: password) { _ in
//                        isPasswordValid = password.count >= 6
//                    }
//                if !isPasswordValid {
//                    Text("Password must be at least 6 characters")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//            
//            Button(action: {
//                if isValidEmail(email) && password.count >= 6 {
//                    authService.login(email: email, password: password)
//                }
//            }) {
//                Text("Login")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .disabled(!isEmailValid || !isPasswordValid)
//            
//            Button("Don't have an account? Sign Up") {
//                isRegistering = true
//            }
//            .foregroundColor(.blue)
//            
//            if let error = authService.error {
//                Text(error)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//        }
//        .padding()
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//}
//
//struct SignUpView: View {
//    @EnvironmentObject var authService: AuthService
//    @Binding var isRegistering: Bool
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var isNameValid = true
//    @State private var isEmailValid = true
//    @State private var isPasswordValid = true
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Create Account")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            
//            VStack(alignment: .leading, spacing: 10) {
//                TextField("Name", text: $name)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .onChange(of: name) { _ in
//                        isNameValid = !name.isEmpty
//                    }
//                if !isNameValid {
//                    Text("Name is required")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 10) {
//                TextField("Email", text: $email)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .autocapitalization(.none)
//                    .onChange(of: email) { _ in
//                        isEmailValid = isValidEmail(email)
//                    }
//                if !isEmailValid {
//                    Text("Please enter a valid email")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 10) {
//                SecureField("Password", text: $password)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .onChange(of: password) { _ in
//                        isPasswordValid = password.count >= 6
//                    }
//                if !isPasswordValid {
//                    Text("Password must be at least 6 characters")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//            
//            Button(action: {
//                if isNameValid && isValidEmail(email) && isPasswordValid {
//                    authService.register(name: name, email: email, password: password, completion: <#(Bool) -> Void#>)
//                }
//            }) {
//                Text("Sign Up")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .disabled(!isNameValid || !isEmailValid || !isPasswordValid)
//            
//            Button("Already have an account? Login") {
//                isRegistering = false
//            }
//            .foregroundColor(.blue)
//            
//            if let error = authService.error {
//                Text(error)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//        }
//        .padding()
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//}
//
//struct LoggedInView: View {
//    @EnvironmentObject var authService: AuthService
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Welcome, \(authService.currentUser?.name ?? "User")!")
//                .font(.title)
//            
//            Button(action: {
//                authService.logout()
//            }) {
//                Text("Logout")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.red)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//    }
//}
