//import Foundation
//import SwiftUI
//
//class AuthService: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var currentUser: User?
//    @Published var error: String?
//    @Published var authToken: String?
//    
//    
//    private let baseURL = "https://url2mobile.smartcrop.com/api/v1"
//    private let tokenKey = "authToken"
//    private let expiresAtKey = "tokenExpiresAt"
// 
//    
//    
//    
//    
//    
//    
//    
//    
//    struct User: Codable {
//        let name: String
//        let email: String
//    }
//    
//    struct AuthResponse: Codable {
//           let resCode: Int
//           let resPhrase: String
//           let resStatus: String
//           let resMsg: String
//           let data: AuthData
//       }
//    struct AuthData: Codable {
//            let token: String
//            let expires_at: String
//        }
//    
//   
//    
//    
//    static let shared = AuthService()
//
//    private init() {
//           checkAuthentication()
//       }
//    
//    
//    
//    private func checkAuthentication() {
//        print("AuthService: Checking authentication")
//        if let token = UserDefaults.standard.string(forKey: tokenKey)
//      
////           let expiresAtString = UserDefaults.standard.string(forKey: expiresAtKey),
////           let expiresAt = ISO8601DateFormatter().date(from: expiresAtString),
////           expiresAt  > Date()
//        {
//            print(authToken)
//            authToken = token
//            isAuthenticated = true
//            print("AuthService: Found valid token, user is authenticated")
//        } else {
//            isAuthenticated = false
//            print("AuthService: No valid token found")
//        }
//        
//    }
//    
//    func register(name: String, email: String, password: String) {
//        print("AuthService: Attempting to register user")
//        guard let url = URL(string: "\(baseURL)/users/store") else {
//            self.error = "Invalid URL"
//            print("AuthService: Invalid URL for registration")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body: [String: Any] = [
//            "name": name,
//            "email": email,
//            "password": password,
//            "password_confirmation": password
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            self.error = "Failed to encode request body"
//            print("AuthService: Failed to encode registration request body - \(error)")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.error = "Registration failed: \(error.localizedDescription)"
//                    print("AuthService: Registration network error - \(error)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    self?.error = "Invalid response from server"
//                    print("AuthService: Invalid response for registration")
//                    return
//                }
//                
//                print("AuthService: Registration response status code - \(httpResponse.statusCode)")
//                
//                if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                    print("AuthService: Registration response data - \(responseString)")
//                    
//                    if responseString.contains("<!DOCTYPE html>") {
//                        self?.error = "Server returned HTML instead of JSON. Please check the API endpoint."
//                        print("AuthService: Received HTML response instead of JSON")
//                        return
//                    }
//                    
//                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201  {
//                        do {
//                            let jsonResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
//                            print("AuthService: Successfully decoded auth response")
//                            // Handle successful registration
//                            self?.login(email: email, password: password)
//                        } catch {
//                            print("AuthService: Failed to decode JSON response - \(error)")
//                            self?.error = "Failed to process registration response: \(error.localizedDescription)"
//                        }
//                    } else {
//                        self?.error = "Registration failed with status code \(httpResponse.statusCode)"
//                        print("AuthService: Registration failed - \(self?.error ?? "Unknown error")")
//                    }
//                } else {
//                    self?.error = "No data received from server"
//                    print("AuthService: No data received from registration request")
//                }
//            }
//        }.resume()
//    }
//
//    
//    func login(email: String, password: String) {
//           print("AuthService: Attempting to log in")
//           guard let url = URL(string: "\(baseURL)/tokens/create") else {
//               self.error = "Invalid URL"
//               print("AuthService: Invalid URL for login")
//               return
//           }
//           
//           var request = URLRequest(url: url)
//           request.httpMethod = "POST"
//           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//           
//           let deviceName = UIDevice.current.name
//           let body: [String: Any] = [
//               "email": email,
//               "password": password,
//               "device_name": deviceName
//           ]
//           
//           do {
//               request.httpBody = try JSONSerialization.data(withJSONObject: body)
//           } catch {
//               self.error = "Failed to encode request body"
//               print("AuthService: Failed to encode login request body - \(error)")
//               return
//           }
//           
//           URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//               DispatchQueue.main.async {
//                   if let error = error {
//                       self?.error = "Login failed: \(error.localizedDescription)"
//                       print("AuthService: Login network error - \(error)")
//                       return
//                   }
//                   
//                   guard let httpResponse = response as? HTTPURLResponse else {
//                       self?.error = "Invalid response from server"
//                       print("AuthService: Invalid response for login")
//                       return
//                   }
//                   
//                   print("AuthService: Login response status code - \(httpResponse.statusCode)")
//                   
//                   guard let data = data else {
//                       self?.error = "No data received from server"
//                       print("AuthService: No data received from login request")
//                       return
//                   }
//                   
//                   print("AuthService: Login response data - \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
//                   
//                   do {
//                       let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
//                       print("AuthService: Successfully decoded auth response")
//                       UserDefaults.standard.set(authResponse.data.token, forKey: self?.tokenKey ?? "")
//                       self?.authToken = authResponse.data.token
//                       print(self?.authToken)
//                      
//                       UserDefaults.standard.set(authResponse.data.expires_at, forKey: self?.expiresAtKey ?? "")
//                       
//                       
//                       self?.isAuthenticated = true
//                       self?.currentUser = User(name: "", email: email)
//                       self?.error = nil
//                       print("AuthService: Login successful, token stored")
//                   } catch {
//                       print("AuthService: Failed to decode login response - \(error)")
//                       if let decodingError = error as? DecodingError {
//                           print("AuthService: Decoding error details - \(decodingError)")
//                       }
//                       self?.error = "Failed to process login response: \(error.localizedDescription)"
//                       print("AuthService: Login failed - \(self?.error ?? "Unknown error")")
//                   }
//               }
//           }.resume()
//       }
//    
//    func logout() {
//        print("AuthService: Attempting to log out")
//        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
//            self.error = "No active session to log out"
//            print("AuthService: No token found for logout")
//            return
//        }
//        
//        guard let url = URL(string: "\(baseURL)/tokens/revoke") else {
//            self.error = "Invalid URL"
//            print("AuthService: Invalid URL for logout")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.error = "Logout failed: \(error.localizedDescription)"
//                    print("AuthService: Logout network error - \(error)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    self?.error = "Invalid response from server"
//                    print("AuthService: Invalid response for logout")
//                    return
//                }
//                
//                print("AuthService: Logout response status code - \(httpResponse.statusCode)")
//                
//                if let data = data {
//                    print("AuthService: Logout response data - \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
//                } else {
//                    print("AuthService: No data received from logout request")
//                }
//                
//                if httpResponse.statusCode == 200 {
//                    UserDefaults.standard.removeObject(forKey: self?.tokenKey ?? "")
//                    UserDefaults.standard.removeObject(forKey: self?.expiresAtKey ?? "")
//                    self?.isAuthenticated = false
//                    self?.currentUser = nil
//                    self?.error = nil
//                    print("AuthService: Logout successful")
//                } else {
//                    self?.error = "Logout failed with status code \(httpResponse.statusCode)"
//                    print("AuthService: Logout failed - \(self?.error ?? "Unknown error")")
//                }
//            }
//        }.resume()
//    }
//    
//    func getAuthHeaders() -> [String: String] {
//            if let token = UserDefaults.standard.string(forKey: tokenKey) {
//                return ["Authorization": "Bearer \(token)"]
//            }
//            return [:]
//        }
//}
//import Foundation
//import SwiftUI
//
//class AuthService: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var currentUser: User?
//    @Published var error: String?
//    @Published var authToken: String?
//    
//    private let baseURL = "https://url2mobile.smartcrop.com/api/v1"
//    private let tokenKey = "authToken"
//    private let expiresAtKey = "tokenExpiresAt"
//    
//    struct User: Codable {
//        let name: String
//        let email: String
//    }
//    
//    struct AuthResponse: Codable {
//        let resCode: Int
//        let resPhrase: String
//        let resStatus: String
//        let resMsg: String
//        let data: AuthData
//    }
//    
//    struct AuthData: Codable {
//        let token: String
//        let expires_at: String
//    }
//    
//    static let shared = AuthService()
//    
//    private init() {
//        checkAuthentication()
//    }
//    
//    private func checkAuthentication() {
//        print("AuthService: Checking authentication")
//        if let token = UserDefaults.standard.string(forKey: tokenKey) {
//            print(authToken)
//            authToken = token
//            isAuthenticated = true
//            print("AuthService: Found valid token, user is authenticated")
//        } else {
//           
//            print("AuthService: No valid token found")
//        }
//    }
//    
//    func register(name: String, email: String, password: String) {
//        print("AuthService: Attempting to register user")
//        guard let url = URL(string: "\(baseURL)/users/store") else {
//            self.error = "Unable to connect to the server. Please try again later."
//            print("AuthService: Invalid URL for registration")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body: [String: Any] = [
//            "name": name,
//            "email": email,
//            "password": password,
//            "password_confirmation": password
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            self.error = "An error occurred while preparing your request. Please try again."
//            print("AuthService: Failed to encode registration request body - \(error)")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.error = "Unable to connect to the server. Please check your internet connection and try again."
//                    print("AuthService: Registration network error - \(error)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    self?.error = "Received an invalid response from the server. Please try again later."
//                    print("AuthService: Invalid response for registration")
//                    return
//                }
//                
//                print("AuthService: Registration response status code - \(httpResponse.statusCode)")
//                
//                if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                    print("AuthService: Registration response data - \(responseString)")
//                    
//                    if responseString.contains("<!DOCTYPE html>") {
//                        self?.error = "The server is currently unavailable. Please try again later."
//                        print("AuthService: Received HTML response instead of JSON")
//                        return
//                    }
//                    
//                    if httpResponse.statusCode == 200 {
//                        do {
//                            let jsonResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
//                            print("AuthService: Successfully decoded auth response")
//                            // Handle successful registration
//                            self?.login(email: email, password: password)
//                        } catch {
//                            print("AuthService: Failed to decode JSON response - \(error)")
//                            self?.error = "An unexpected error occurred. Please try again later."
//                        }
//                    } else {
//                        // Handle different error cases
//                        switch httpResponse.statusCode {
//                        case 400:
//                            self?.error = "The provided information is invalid. Please check your details and try again."
//                        case 409:
//                            self?.error = "An account with this email already exists. Please use a different email or try logging in."
//                        case 422:
//                            self?.error = "The provided data is invalid. Please check all fields and try again."
//                        default:
//                            self?.error = "An unexpected error occurred. Please try again later."
//                        }
//                        print("AuthService: Registration failed - \(self?.error ?? "Unknown error")")
//                    }
//                } else {
//                    self?.error = "No response received from the server. Please try again later."
//                    print("AuthService: No data received from registration request")
//                }
//            }
//        }.resume()
//    }
//    
//    func login(email: String, password: String) {
//        print("AuthService: Attempting to log in")
//        guard let url = URL(string: "\(baseURL)/tokens/create") else {
//            self.error = "Unable to connect to the server. Please try again later."
//            print("AuthService: Invalid URL for login")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let deviceName = UIDevice.current.name
//        let body: [String: Any] = [
//            "email": email,
//            "password": password,
//            "device_name": deviceName
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            self.error = "An error occurred while preparing your request. Please try again."
//            print("AuthService: Failed to encode login request body - \(error)")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.error = "Unable to connect to the server. Please check your internet connection and try again."
//                    print("AuthService: Login network error - \(error)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    self?.error = "Received an invalid response from the server. Please try again later."
//                    print("AuthService: Invalid response for login")
//                    return
//                }
//                
//                print("AuthService: Login response status code - \(httpResponse.statusCode)")
//                
//                guard let data = data else {
//                    self?.error = "No response received from the server. Please try again later."
//                    print("AuthService: No data received from login request")
//                    return
//                }
//                
//                print("AuthService: Login response data - \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
//                
//                do {
//                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
//                    print("AuthService: Successfully decoded auth response")
//                    UserDefaults.standard.set(authResponse.data.token, forKey: self?.tokenKey ?? "")
//                    self?.authToken = authResponse.data.token
//                    print(self?.authToken)
//                    
//                    UserDefaults.standard.set(authResponse.data.expires_at, forKey: self?.expiresAtKey ?? "")
//                    
//                    self?.isAuthenticated = true
//                    self?.currentUser = User(name: "", email: email)
//                    self?.error = nil
//                    print("AuthService: Login successful, token stored")
//                } catch {
//                    print("AuthService: Failed to decode login response - \(error)")
//                    if let decodingError = error as? DecodingError {
//                        print("AuthService: Decoding error details - \(decodingError)")
//                    }
//                    // Handle different error cases
//                    switch httpResponse.statusCode {
//                    case 400:
//                        self?.error = "Invalid email or password. Please check your credentials and try again."
//                    case 401:
//                        self?.error = "Incorrect email or password. Please try again."
//                    case 403:
//                        self?.error = "Your account is currently locked. Please contact support for assistance."
//                    default:
//                        self?.error = "An unexpected error occurred during login. Please try again later."
//                    }
//                    print("AuthService: Login failed - \(self?.error ?? "Unknown error")")
//                }
//            }
//        }.resume()
//    }
//    
//    func logout() {
//        print("AuthService: Attempting to log out")
//        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
//            self.error = "You are not currently logged in."
//            print("AuthService: No token found for logout")
//            return
//        }
//        
//        guard let url = URL(string: "\(baseURL)/tokens/revoke") else {
//            self.error = "Unable to connect to the server. Please try again later."
//            print("AuthService: Invalid URL for logout")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.error = "Unable to connect to the server. Please check your internet connection and try again."
//                    print("AuthService: Logout network error - \(error)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    self?.error = "Received an invalid response from the server. Please try again later."
//                    print("AuthService: Invalid response for logout")
//                    return
//                }
//                
//                print("AuthService: Logout response status code - \(httpResponse.statusCode)")
//                
//                if let data = data {
//                    print("AuthService: Logout response data - \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
//                } else {
//                    print("AuthService: No data received from logout request")
//                }
//                
//                if httpResponse.statusCode == 200 {
//                    UserDefaults.standard.removeObject(forKey: self?.tokenKey ?? "")
//                    UserDefaults.standard.removeObject(forKey: self?.expiresAtKey ?? "")
//                    self?.isAuthenticated = false
//                    self?.currentUser = nil
//                    self?.error = nil
//                    print("AuthService: Logout successful")
//                } else {
//                    // Handle different error cases
//                    switch httpResponse.statusCode {
//                    case 401:
//                        self?.error = "Your session has expired. Please log in again."
//                    default:
//                        self?.error = "An error occurred during logout. Please try again later."
//                    }
//                    print("AuthService: Logout failed - \(self?.error ?? "Unknown error")")
//                }
//            }
//        }.resume()
//    }
//    
//    func getAuthHeaders() -> [String: String] {
//        if let token = UserDefaults.standard.string(forKey: tokenKey) {
//            return ["Authorization": "Bearer \(token)"]
//        }
//        return [:]
//    }
//}
import Foundation
import SwiftUI

class AuthService: ObservableObject {
 
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var error: String?
    @Published var authToken: String?
    
    private let baseURL = "https://url2mobile.smartcrop.com/api/v1"
    private let tokenKey = "authToken"
    private let expiresAtKey = "tokenExpiresAt"
 
    var errors:String {
        return error ?? ""
    }
    
    struct User: Codable {
        let name: String
        let email: String
    }
    
    
    struct LAuthResponse: Codable {
           let resCode: Int
           let resPhrase: String
           let resStatus: String
           let resMsg: String
           let data: AuthData
       }
    struct AuthResponse: Codable {
        let resCode: Int
        let resPhrase: String
        let resStatus: String
        let resMsg: String
        let data: [AuthData]
    }
    
    struct AuthData: Codable {
        let token: String
        let expires_at: String
    }
    
    static let shared = AuthService()

    private init() {
           checkAuthentication()
       }
    
    
    
    private func checkAuthentication() {
        print("AuthService: Checking authentication")
        if let token = UserDefaults.standard.string(forKey: tokenKey)
      
//           let expiresAtString = UserDefaults.standard.string(forKey: expiresAtKey),
//           let expiresAt = ISO8601DateFormatter().date(from: expiresAtString),
//           expiresAt  > Date()
        {
            print(authToken)
            authToken = token
            isAuthenticated = true
            print("AuthService: Found valid token, user is authenticated")
        } else {
            isAuthenticated = false
            print("AuthService: No valid token found")
        }
        
    }
    func register(name: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/store") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "password_confirmation": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(false, "Failed to encode request body")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "Registration failed: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(false, "Invalid response from server")
                    return
                }
                
                if httpResponse.statusCode == 201 {
                    self?.login(email: email, password: password, completion: completion)
                } else {
                    if let data = data {
                        do {
                            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                            completion(false, authResponse.resMsg)
                        } catch {
                            completion(false, "Failed to decode error response")
                        }
                    } else {
                        completion(false, "Registration failed with status code \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }

//    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
//        guard let url = URL(string: "\(baseURL)/tokens/create") else {
//            completion(false, "Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let deviceName = UIDevice.current.name
//        let body: [String: Any] = [
//            "email": email,
//            "password": password,
//            "device_name": deviceName
//        ]
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            completion(false, "Failed to encode request body")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    completion(false, "Login failed: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    completion(false, "Invalid response from server")
//                    return
//                }
//                
//                guard let data = data else {
//                    completion(false, "No data received from server")
//                    return
//                }
//                
//                do {
//                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
//                    
//                    UserDefaults.standard.set(authResponse.data[0].token, forKey: self?.tokenKey ?? "")
//                    self?.authToken = authResponse.data[0].token
//                    UserDefaults.standard.set(authResponse.data[0].expires_at, forKey: self?.expiresAtKey ?? "")
//                    
//                    self?.isAuthenticated = true
//                    self?.currentUser = User(name: "", email: email)
//                    self?.error = nil
//                    completion(true, nil)
//                } catch {
//                    completion(false, "Failed to process login response: \(error.localizedDescription)")
//                }
//            }
//        }.resume()
//    }
    
    func login(email: String, password: String , completion: @escaping (Bool, String?)-> Void) {
           print("AuthService: Attempting to log in")
           guard let url = URL(string: "\(baseURL)/tokens/create") else {
               self.error = "Invalid URL"
               print("AuthService: Invalid URL for login")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           let deviceName = UIDevice.current.name
           let body: [String: Any] = [
               "email": email,
               "password": password,
               "device_name": deviceName
           ]
           
           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: body)
           } catch {
               completion(false, "Failed to encode request body")
               //
               self.error = "Failed to encode request body"
               print("AuthService: Failed to encode login request body - \(error)")
               return
           }
           
           URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
               DispatchQueue.main.async {
                   if let error = error {
                       completion(false, "Login failed: \(error.localizedDescription)")
                       //                    return
                       self?.error = "Login failed: \(error.localizedDescription)"
                       print("AuthService: Login network error - \(error)")
                       return
                   }
                   
                   guard let httpResponse = response as? HTTPURLResponse else {
                       self?.error = "Invalid response from server"
                       print("AuthService: Invalid response for login")
                       return
                   }
                   
                   print("AuthService: Login response status code - \(httpResponse.statusCode)")
                   
                  
                   
                   
                   guard let data = data else {
                       completion(false, "No data received from server")
                       //                    return
                       self?.error = "No data received from server"
                       print("AuthService: No data received from login request")
                       return
                   }
                  
                   print("AuthService: Login response data - \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                   
                   do {
                       
                       
                       
                       if  httpResponse.statusCode != 200 {
                           let tauthResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                           self?.error = tauthResponse.resMsg
                           print("hola")
                           print(tauthResponse.resMsg,tauthResponse.resStatus,tauthResponse.data)
                           completion(false, tauthResponse.resMsg)
                           return
                          
                         
                       }else {
                           let authResponse = try JSONDecoder().decode(LAuthResponse.self, from: data)
                           print("AuthService: Successfully decoded auth response")
                           
                           print("AuthService: Successfully decoded auth response")
                           UserDefaults.standard.set(authResponse.data.token, forKey: self?.tokenKey ?? "")
                           self?.authToken = authResponse.data.token
                           print(self?.authToken)
                           print(self?.authToken)
                          
                           UserDefaults.standard.set(authResponse.data.expires_at, forKey: self?.expiresAtKey ?? "")
                           
                           
                           self?.isAuthenticated = true
                           self?.currentUser = User(name: "", email: email)
                           self?.error = nil
                           completion(true, nil)
                           print("AuthService: Login successful, token stored")
                       }
                      
                   } catch {
                       print("AuthService: Failed to decode login response - \(error)")
                       if let decodingError = error as? DecodingError {
                           print("AuthService: Decoding error details - \(decodingError)")
                       }
                       self?.error = "Failed to process login response: \(error.localizedDescription)"
                       print("AuthService: Login failed - \(self?.error ?? "Unknown error")")
                   }
               }
           }.resume()
       }
    
    func logout() {
        print("AuthService: Attempting to log out")
        guard let token = UserDefaults.standard.string(forKey: tokenKey) else {
            self.error = "No active session to log out"
            print("AuthService: No token found for logout")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/tokens/revoke") else {
            self.error = "Invalid URL"
            print("AuthService: Invalid URL for logout")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.error = "Logout failed: \(error.localizedDescription)"
                    print("AuthService: Logout network error - \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.error = "Invalid response from server"
                    print("AuthService: Invalid response for logout")
                    return
                }
                
                print("AuthService: Logout response status code - \(httpResponse.statusCode)")
                
                if let data = data {
                    print("AuthService: Logout response data - \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                } else {
                    print("AuthService: No data received from logout request")
                }
                
                if httpResponse.statusCode == 200 {
                    UserDefaults.standard.removeObject(forKey: self?.tokenKey ?? "")
                    UserDefaults.standard.removeObject(forKey: self?.expiresAtKey ?? "")
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                    self?.error = nil
                    print("AuthService: Logout successful")
                } else {
                    self?.error = "Logout failed with status code \(httpResponse.statusCode)"
                    print("AuthService: Logout failed - \(self?.error ?? "Unknown error")")
                }
            }
        }.resume()
    }
    
    func getAuthHeaders() -> [String: String] {
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            return ["Authorization": "Bearer \(token)"]
        }
        return [:]
    }
}
