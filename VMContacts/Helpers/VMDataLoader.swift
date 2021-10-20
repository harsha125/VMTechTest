//
//  VMDataLoader.swift
//  VMContacts
//
//  Created by Harsha on 05/10/2021.
//

import Foundation

protocol DataLoaderProtocol {
    var client: APICommunicationProviding { get }
    typealias Result = Swift.Result<[Codable], Error>
    func loadData<T: Codable>(for _: T.Type, from url: URL, completion: @escaping (Result) -> Void)
}

final class DataLoader: DataLoaderProtocol {
    
    enum Error: Swift.Error {
        case connectivity, invalidData
    }
    
    
    typealias Result = DataLoaderProtocol.Result

    let client: APICommunicationProviding
    
    init(client: APICommunicationProviding) {
        self.client = client
    }
    
    func loadData<T: Codable>(for _: T.Type, from url: URL, completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case .success((let data)):
                do {
                    let persons = try JSONItemsMapper<[T]>.decodeAndMap(data)
                    return completion(.success(persons))
                } catch {
                    return completion(.failure(Error.invalidData))
                }
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

}


final class JSONItemsMapper<T: Decodable> {
    
    static func decodeAndMap(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decodable = try? decoder.decode(T.self, from: data) else {
            throw DataLoader.Error.invalidData
        }
        return decodable
    }
}

