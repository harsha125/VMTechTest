//
//  ApplicationContext.swift
//  VMContacts
//
//  Created by Harsha on 04/10/2021.
//

import Foundation

protocol ApplicationContextProviding {
    var apiCommunicator: APICommunicationProviding { get }

}

final class ApplicationContext: ApplicationContextProviding {
    let apiCommunicator: APICommunicationProviding
    init(apiCommunicator: APICommunicationProviding) {
        self.apiCommunicator = apiCommunicator
    }
}



struct UnexpectedValueRepresentation: Error {}

protocol APICommunicationProviding {
    var session: URLSession { get }
    typealias Result = Swift.Result<Data, Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
struct HttpStatusCode {
    static let OK_200 = 200
}

class APICommunicator: APICommunicationProviding {
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (APICommunicationProviding.Result) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, (response as? HTTPURLResponse)?.statusCode == HttpStatusCode.OK_200  {
                    return data
                } else {
                    throw UnexpectedValueRepresentation()
                }
            })
        }.resume()
    }
}


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

protocol AppConfigurationProviding {
    var peopleURL: URL { get }
    var roomsURL: URL { get }
}


class AppConfig: AppConfigurationProviding {
    static let shared = AppConfig()
    let peopleURL: URL = Constants.EndPoints.people.knownUrl
    let roomsURL: URL = Constants.EndPoints.rooms.knownUrl
    private init() { }
}
