//  Extensions.swift
//  betMLB
//  Created by Andrew Xin on 8/3/24.

import Foundation
import SwiftUI

extension View {
    // sets up tabs
    @ViewBuilder func setUpTab(_ tab: Tab) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(tab)
            .toolbar(.hidden, for: .tabBar)
    }
    
    // extracts dates for given month
    func extractDates(_ month: Date) -> [Day] {
        var days: [Day] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        // Get the range of days in the month
        guard let range = calendar.range(of: .day, in: .month, for: month) else {
            return days
        }
        
        // Get the first and last day of the month
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let lastOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: firstOfMonth)!
        
        // Calculate the first weekday of the month
        let firstWeekDay = calendar.component(.weekday, from: firstOfMonth)
        
        // Pad the beginning of the month with days from the previous month
        for index in 0..<firstWeekDay - 1 {
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: firstOfMonth) else { return days }
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
        }
        
        // Add days for the current month
        for day in 0..<range.count {
            guard let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) else { return days }
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date))
        }
        
        // Calculate the last weekday of the month
        let lastWeekDay = calendar.component(.weekday, from: lastOfMonth)
        
        // Pad the end of the month with days from the next month
        if lastWeekDay < 7 {
            for index in lastWeekDay..<7 {
                guard let date = calendar.date(byAdding: .day, value: index - lastWeekDay + 1, to: lastOfMonth) else { return days }
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }
        
        return days
    }
}

extension Date {
    // returns current month's starting date
    static var currentMonth: Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: Calendar.current.dateComponents([.month, .year], from: .now)) else {
            return .now
        }
        return currentMonth
    }
    
    // Changes a date to this format: 6/1/1999
    func formatToMDY() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy" // Desired format
        return dateFormatter.string(from: self)
    }
}

extension String {
    // Changes a string to a date
    func toDate(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
