//
//  AppConfig.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import Foundation

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
