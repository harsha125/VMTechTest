//
//  Utils.swift
//  VMContacts
//
//  Created by Harsha on 19/10/2021.
//

import Foundation

extension DateFormatter {
    static let longdate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
