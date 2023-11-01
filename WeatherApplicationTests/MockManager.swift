//
//  MockManager.swift
//  WeatherApplicationTests
//
//  Created by Ronnie Kissos on 11/1/23.
//

import Foundation
@testable import WeatherApplication

class MockManager: Networking {
    func request<T>(url: String, modelType: T.Type) async throws -> T where T : Decodable {
        let bundle = Bundle(for: MockManager.self)
        guard let urlObj = URL(string: url) else { throw NetworkError.invalidUrl}

        guard let path = bundle.url(forResource: urlObj.absoluteString, withExtension: "json") else { throw NetworkError.invalidUrl }
        do {
            let decoder =  JSONDecoder()
            let data = try Data(contentsOf: path)

            let parssedData = try decoder.decode(modelType.self, from: data)
            return parssedData
        }catch{
            throw error
        }
    }
}
