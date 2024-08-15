//  CalendarViewVM.swift
//  betMLB
//  Created by Andrew Xin on 8/13/24.

import Foundation

@Observable class CalendarViewVM {
    private let fetcher = Fetcher()
    var selectedMonth: Date = .currentMonth {
        didSet {
            Task {
                await loadGames()
            }
        }
    }
    var selectedDate: Date = .now {
        didSet {
            Task {
                await loadGames()
            }
        }
    }
    var showOnlyActiveGames = false
    var schedule: [ScheduleDate] = []
    
    func loadGames() async {
        do {
            self.schedule = try await fetcher.fetchSchedule(date: selectedDate)
        } catch {
            print("loadGames: Error fetching data")
        }
    }
}
