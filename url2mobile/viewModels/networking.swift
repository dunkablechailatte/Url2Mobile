//import Foundation
//import Combine
//import SwiftUI
//
//struct Link: Identifiable, Codable {
//    let id: Int
//    let url: String
//    let type: String
//    let created_at: String
//}
//
//class LinkViewModel: ObservableObject {
//    @Published var links: [Link] = []
//    @Published var filteredLinks: [Link] = []
//    @Published var isLoading: Bool = false
//    
//
//    
//    private var cancellables = Set<AnyCancellable>()
//    private let baseURL = "https://url2mobile.smartcrop.com/api/v1/links"
//    private var authToken = AuthService.shared.authToken ?? ""
//    
//    
//
//
//        init() {
//            print(authToken)
//            fetchLinks()
//            
//        }
//        
//        func fetchLinks() {
//            guard let url = URL(string: baseURL) else { return }
//            
//            var request = URLRequest(url: url)
//            request.addValue("Bearer \(AuthService.shared.authToken ?? "")", forHTTPHeaderField: "Authorization")
//            
//            isLoading = true
//            
//            URLSession.shared.dataTaskPublisher(for: request)
//                .map(\.data)
//                .decode(type: APIResponse.self, decoder: JSONDecoder())
//                .receive(on: DispatchQueue.main)
//                .sink { completion in
//                    self.isLoading = false
//                    if case .failure(let error) = completion {
//                        print("Error fetching links: \(error)")
//                    }
//                } receiveValue: { response in
//                    self.links = response.data
//                    self.filteredLinks = response.data
//                    print(self.links)
//                    print(response)
//                }
//                .store(in: &cancellables)
//        }
//    
//    func createLink(url: String, type: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let requestURL = URL(string: baseURL) else { return }
//        
//        var request = URLRequest(url: requestURL)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let body = "url=\(url)&type=\(type)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
//        request.httpBody = body.data(using: .utf8)
//        
//        print("Creating link with URL: \(url) and type: \(type)")
//        
//        URLSession.shared.dataTaskPublisher(for: request)
//            .map(\.data)
//            .decode(type: APIResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink { completionResult in
//                if case .failure(let error) = completionResult {
//                    print("Error creating link: \(error)")
//                    completion(.failure(error))
//                }
//            } receiveValue: { response in
//                print("Successfully created link. Fetching updated links.")
//                self.fetchLinks()
//                print(self.links)
//                print(response)
//                completion(.success(()))
//            }
//            .store(in: &cancellables)
//    }
//    
//    func deleteLink(id: Int) {
//        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        
//        print("Deleting link with ID: \(id)")
//        
//        URLSession.shared.dataTaskPublisher(for: request)
//            .map(\.data)
//            .decode(type: APIResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                if case .failure(let error) = completion {
//                    print("Error deleting link: \(error)")
//                }
//            } receiveValue: { _ in
//                print("Successfully deleted link. Fetching updated links.")
//                if self.filteredLinks.count <= 1 {
//                    self.fetchLinks()
//                    print("ooooooooo deleting + fetching")
//                }
//              
//              
//            }
//    
//            .store(in: &cancellables)
//       
//    }
//    
//    func filterLinks(with searchText: String) {
//        if searchText.isEmpty {
//            filteredLinks = links
//        } else {
//            filteredLinks = links.filter { $0.url.lowercased().contains(searchText.lowercased()) }
//        }
//        print("Filtered links with search text '\(searchText)': \(filteredLinks)")
//    }
//}
//
//struct APIResponse: Codable {
//    let resCode: Int
//    let resPhrase: String
//    let resStatus: String
//    let resMsg: String
//    let data: [Link]
//}
//
import Foundation
import Combine
import SwiftUI

struct Link: Identifiable, Codable {
    let id: Int
    let url: String
    let type: String
    let created_at: String
}

class LinkViewModel: ObservableObject {
    @Published var links: [Link] = []
    @Published var filteredLinks: [Link] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://url2mobile.smartcrop.com/api/v1/links"
    private var authToken = AuthService.shared.authToken ?? ""
    
    
    init() {
        print(authToken)
        fetchLinks()
        
    }
    
    func fetchLinks() {
        guard let url = URL(string: baseURL) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(AuthService.shared.authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching links: \(error)")
                }
            } receiveValue: { response in
                self.links = response.data
                self.filteredLinks = response.data
                print(self.links)
                print(response)
            }
            .store(in: &cancellables)
    }

func createLink(url: String, type: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let requestURL = URL(string: baseURL) else { return }
    
    var request = URLRequest(url: requestURL)
    request.httpMethod = "POST"
    request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let body = "url=\(url)&type=\(type)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    request.httpBody = body.data(using: .utf8)
    
    print("Creating link with URL: \(url) and type: \(type)")
    
    URLSession.shared.dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: APIResponse.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .sink { completionResult in
            if case .failure(let error) = completionResult {
                print("Error creating link: \(error)")
                completion(.failure(error))
            }
        } receiveValue: { response in
            print("Successfully created link. Fetching updated links.")
            self.fetchLinks()
            print(self.links)
            print(response)
            completion(.success(()))
        }
        .store(in: &cancellables)
}
    
    func deleteLink(id: Int) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error deleting link: \(error)")
                }
            } receiveValue: { _ in
                self.links.removeAll { $0.id == id }
                self.filteredLinks.removeAll { $0.id == id }
            }
            .store(in: &cancellables)
    }
    
    func filterLinks(with searchText: String) {
        if searchText.isEmpty {
            filteredLinks = links
        } else {
            filteredLinks = links.filter { $0.url.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct APIResponse: Codable {
    let resCode: Int
    let resPhrase: String
    let resStatus: String
    let resMsg: String
    let data: [Link]
}
