//  Extensions.swift
//  betMLB
//  Created by Andrew Xin on 8/3/24.

import Foundation
import SwiftUI
import SDWebImageSwiftUI

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
    
    // Cleaning up search text by removing accents from characters
    func removingDiacritics() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    // Formats a date like: "2024-07-08T16:35:00Z
    func formattedGameTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: date)
        }
        return self
    }
}

extension Color {
    init(hex: String) {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedHex = cleanedHex.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}


extension Image {
    static func teamLogoImage(for teamId: Int) -> some View {
        WebImage(url: URL(string: "https://www.mlbstatic.com/team-logos/\(teamId).svg"))
            .resizable()
            .scaledToFit()
    }
}
