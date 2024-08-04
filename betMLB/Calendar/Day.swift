//  Day.swift
//  betMLB
//  Created by Andrew Xin on 8/3/24.

import Foundation

struct Day: Identifiable {
    var id: UUID = .init()
    var shortSymbol: String
    var date: Date
    // Previous/Next Month Excess Dates
    var ignored: Bool = false
}
