//  CalendarViewVM.swift
//  betMLB
//  Created by Andrew Xin on 8/13/24.

import Foundation

@Observable class CalendarViewVM {
    private let fetcher = Fetcher()
    var selectedMonth: Date = .currentMonth
    var selectedDate: Date = .now
}
