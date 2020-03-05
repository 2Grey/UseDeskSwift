//
//  Date+Extension.swift
//  Classes
//
//  Created by Sergey Ryazanov on 05.03.2020.
//

import Foundation

extension Date {
    var isToday: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        let date1 = dateFormatter.string(from: self)
        let date2 = dateFormatter.string(from: Date())
        if date1 == date2 {
            return true
        } else {
            return false
        }
    }

    var timeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return dateFormatter.string(from: self)
    }

    var timeAndDayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return dateFormatter.string(from: self)
    }

    var dateFromHeaderComments: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone.current
        var dayString = ""
        if calendar.isDateInYesterday(self) {
            dayString = "Вчера"
        } else if calendar.isDateInToday(self) {
            dayString = "Сегодня"
        } else {
            dateFormatter.dateFormat = "d MMMM"
            dayString = dateFormatter.string(from: self)
        }
        return dayString + " " + self.timeString//dateFormatter.string(from: self)
    }
}
