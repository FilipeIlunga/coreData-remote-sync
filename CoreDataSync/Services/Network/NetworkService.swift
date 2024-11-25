//  NetworkService.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    // Sua API Key
    private let apiKey = "" 
    
    func sendData(entityName: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://hqlorynolbqupzpwhohf.supabase.co/rest/v1/\(entityName)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apiKey") 

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(NetworkError.serializationError))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { tes, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }

    func fetchData(entityName: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard let url = URL(string: "https://hqlorynolbqupzpwhohf.supabase.co/rest/v1/\(entityName)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apiKey") 
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    completion(.success(jsonArray))
                } else {
                    completion(.failure(NetworkError.serializationError))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case serializationError
    case noData
}
