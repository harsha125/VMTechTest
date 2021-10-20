//
//  Constants.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import Foundation

enum Constants {
    enum EndPoints: String {
        case people = "people"
        case rooms = "rooms"
        static let baseURL = "https://5f7c2c8400bd74001690a583.mockapi.io/api/v1/"
        var knownUrl: URL {
            URL(string: Self.baseURL + rawValue)!
        }
    }
}

