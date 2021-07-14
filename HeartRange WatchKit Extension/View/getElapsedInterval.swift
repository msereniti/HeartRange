//
//  getElapsedInterval.swift
//  heart-rate-display WatchKit Extension
//
//  Created by Mikhail Kryuchkov on 6/10/21.
//

import Foundation
import SwiftUI

extension Date {
    func getElapsedInterval(from: Date, to: Date) -> LocalizedStringKey {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from, to: to)

        if let year = interval.year, year > 0 {
            return year == 1 ? "timeInterval.year" :
                "timeInterval.yearsExact \(year)"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "timeInterval.month" :
                "timeInterval.monthsExact \(month)"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "timeInterval.day" :
                "timeInterval.daysExact \(day)"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "timeInterval.hour" :
                "timeInterval.hoursExact \(hour)"
        } else if let minute = interval.minute, minute > 9 {
            return "timeInterval.minutes \((minute / 10) * 10)"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "timeInterval.minute" :
                "timeInterval.minutesExact \(minute)"
        } else if let second = interval.second, second > 9 {
            return "timeInterval.seconds \((second / 10) * 10)"
        } else if let second = interval.second, second > 5 {
            return "timeInterval.about6seconds"
        } else {
            return "timeInterval.moment"
        }
    }
}

