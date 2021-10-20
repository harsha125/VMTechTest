//
//  PersonItem.swift
//  VMContacts
//
//  Created by Harsha on 20/10/2021.
//

import Foundation

struct PersonItem: BaseModelItem {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let email: String?
    let jobTitle: String?
    let createdOn: Date?
    let avtarURL: String?
    let colorCode: String?
    
    var fullName: String {
        [firstName, lastName].compactMap { $0 }
            .filter{ $0.isEmpty == false }
            .joined(separator: " ")
    }
    var formattedCreationDate: String {
        guard let createdOn = createdOn
        else { return "-"}
        return DateFormatter.longdate.string(from: createdOn)
    }
    
    init(from responseObject: Person) {
        self.firstName = responseObject.firstName
        self.lastName = responseObject.lastName
        self.phoneNumber = responseObject.phone
        self.email = responseObject.email
        self.jobTitle = responseObject.jobTitle
        self.avtarURL = responseObject.avatar
        self.createdOn = responseObject.createdAt
        self.colorCode = responseObject.favouriteColor
    }
}
