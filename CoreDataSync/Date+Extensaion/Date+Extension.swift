//
//  Date+Extension.swift
//  CoreDataSync
//
//  Created by Filipe Ilunga on 24/11/24.
//

import Foundation

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

    static func fromISO8601String(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
}
