//
//  DateUtils.swift
//  PotatoPlanner
//
//  Created by Madeline Moody on 3/10/26.
//

import Foundation

extension Date {
    func ttyOrMediumDate(calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            return Date.mediumFormatter.string(from: self)
        }
    }

    var mediumDate: String {
        Date.mediumFormatter.string(from: self)
    }
    
    private static let mediumFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
