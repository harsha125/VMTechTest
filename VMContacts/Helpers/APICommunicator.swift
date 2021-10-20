//
//  APICommunicator.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import Foundation

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
