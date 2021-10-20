//
//  Room.swift
//  VMContacts
//
//  Created by Harsha on 04/10/2021.
//

import Foundation

struct Room: Codable {
    let id: String?
    let createdOn: Date?
    let name: String?
    let maxOccupancy: Int?
    var isOccupied = false
    private enum CodingKeys: String, CodingKey {
        case id, name
        case createdOn = "created_at"
        case maxOccupancy = "max_occupancy"
        case isOccupied = "is_occupied"
    }
}
