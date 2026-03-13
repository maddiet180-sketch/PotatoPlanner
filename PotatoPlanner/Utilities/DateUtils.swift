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
            return mediumFormated(self)
        }
    }

    var mediumDate: String {
        mediumFormated(self)
    }
    
    private func mediumFormated(_ date: Date) -> String {
        String(date.formatted(
            .dateTime
                .weekday(.wide)
                .month(.abbreviated)
                .day()
        ))
    }
}
