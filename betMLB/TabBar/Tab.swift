//  Tab.swift
//  betMLB
//  Created by Andrew Xin on 8/3/24.

import Foundation

enum Tab: String, CaseIterable {
    case calendar = "calendar.circle.fill"
    case players = "person.circle.fill"
    case teams = "person.2.circle.fill"
    case bookmarks = "bookmark.circle.fill"
    
    var title: String {
        switch self {
        case .calendar:
            return "Calendar"
        case .players:
            return "Players"
        case .teams:
            return "Teams"
        case .bookmarks:
            return "Bookmarks"
        }
    }
}

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}
