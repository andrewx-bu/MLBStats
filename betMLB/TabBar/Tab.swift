//  Tab.swift
//  betMLB
//  Created by Andrew Xin on 8/3/24.

import Foundation

enum Tab: String, CaseIterable {
    case home = "house.circle.fill"
    case calendar = "calendar.circle.fill"
    case bookmarks = "bookmark.circle.fill"
    case profile = "person.crop.circle.fill"
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .calendar:
            return "Calendar"
        case .bookmarks:
            return "Bookmarks"
        case .profile:
            return "Profile"
        }
    }
}

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}
