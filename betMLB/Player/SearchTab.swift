//  SearchTab.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import Foundation

enum PlayerTab: String, CaseIterable {
    case all = "All"
    case hitter = "Designated Hitter"
    case pitcher = "Pitcher"
    case fielder = "Fielder"
    case catcher = "Catcher"
}

enum TeamTab: String, CaseIterable {
    case all = "All"
    case americanLeague = "American League"
    case nationalLeague = "National League"
}
