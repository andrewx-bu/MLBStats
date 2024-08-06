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
}

extension String {
    // For getting headshot images from strings like <a href=\"statss.aspx?playerid=15640&position=OF\">Aaron Judge</a>
    func extractQuery() -> String? {
        // Define a regex pattern to match the query part and ensure it ends at the position value
        let pattern = "\\?playerid=[^&]+&position=[^\">]+"
        
        // Create a regular expression with the pattern
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        // Find matches in the string
        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        
        // Return the first match if available
        if let match = matches.first {
            return (self as NSString).substring(with: match.range)
        }
        
        return nil
    }
}
