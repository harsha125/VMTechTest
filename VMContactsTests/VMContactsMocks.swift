//
//  VMContactsMocks.swift
//  VMContactsTests
//
//  Created by Harsha on 21/10/2021.
//

import Foundation
@testable import VMContacts

var peopleJSONData: Data? = {
    let jsonPath = Bundle.main.url(forResource: "people", withExtension: "json")!
    let jsonData = try? Data(contentsOf: jsonPath)
    return jsonData
}()

var roomsJSONData: Data? = {
    let jsonPath = Bundle.main.url(forResource: "rooms", withExtension: "json")!
    let jsonData = try? Data(contentsOf: jsonPath)
    return jsonData
}()

class AppConfigMock: AppConfigurationProviding {
    let peopleURL: URL = URL(string: "http://localhost/people.json")!
    
    let roomsURL: URL = URL(string: "http://localhost/rooms.json")!
    static let shared = AppConfigMock()
    private init() { }
}

class APICOmmunicatorMock: APICommunicationProviding {
    var session: URLSession = .shared
    
    func get(from url: URL, completion: @escaping (APICommunicationProviding.Result) -> Void) {
    //check if uitests are running OR unit tests are running
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(APICommunicationProviding.Result {
                switch url {
                case AppConfigMock.shared.peopleURL:
                    return (peopleJSONData!)
                case AppConfigMock.shared.roomsURL:
                    return (roomsJSONData!)
                default:
                    return (Data())
                }
            })
        }
    }
    
}
