//
//  JSONItemsMapper.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import Foundation

final class JSONItemsMapper<T: Decodable> {
    
    static func decodeAndMap(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        guard let decodable = try? decoder.decode(T.self, from: data) else {
            throw DataLoader.Error.invalidData
        }
        return decodable
    }
}
