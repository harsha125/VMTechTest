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
    
    
    static let iso8601Full: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      return formatter
    }()

}
