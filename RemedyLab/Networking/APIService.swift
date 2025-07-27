//
//  APIService.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

//
//  APIService.swift
//  RemedyLab
//
//  Created by Nivetha Sri on 17/07/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode the server response."
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private init() {}

    private let baseURL = "http://127.0.0.1:8000/api" // Change for production

    func post<T: Codable, U: Codable>(
        endpoint: String,
        payload: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        print(url)
        print(payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            if !(200...299).contains(httpResponse.statusCode) {
                let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
                print(message)
                throw APIError.serverError(message)
            }
            if httpResponse.statusCode == 200 {
                let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
                print("API reposne" , message)
            }
            do {
                return try JSONDecoder().decode(U.self, from: data)
            } catch {
                print("❌ Decoding Error:", error)
                throw APIError.decodingError
            }
        } catch {
            throw APIError.networkError(error.localizedDescription) // ✅ FIXED
        }
    }
}
