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
