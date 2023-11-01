//
//  NetworkManager.swift
//  WeatherApplication
//
//  Created by Ronnie Kissos on 11/1/23.
//

import Foundation

enum NetworkError: Error {
    case invalidUrl
}

protocol Networking {
    func request<T: Decodable>(url: String, modelType: T.Type)async throws -> T
}

class NetworkManager: Networking {
    
    func request<T>(url: String, modelType: T.Type) async throws -> T where T : Decodable {
        
        guard let urlObj = URL(string: url) else { throw NetworkError.invalidUrl}
        
        let (data, _) = try await URLSession.shared.data(from: urlObj)
        do {
            let decoder =  JSONDecoder()
            let parssedData = try decoder.decode(modelType.self, from: data)
            return parssedData
        }catch{
            throw error
        }
    }
}
