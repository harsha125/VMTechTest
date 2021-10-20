//
//  RoomItem.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import Foundation

struct RoomItem: BaseModelItem {
    let name: String?
    let size: Int
    let isOccupied: Bool
    let createdOn: Date?
    
    var formattedCreationDate: String {
        guard let createdOn = createdOn
        else { return "-"}
        return DateFormatter.longdate.string(from: createdOn)
    }

    init(from responseObject: Room) {
        self.name = responseObject.name
        self.size = responseObject.maxOccupancy ?? 0
        self.isOccupied = responseObject.isOccupied
        self.createdOn = responseObject.createdOn
    }
}
