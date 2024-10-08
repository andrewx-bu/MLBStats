//  LazyNavigationView.swift
//  betMLB
//  Created by Andrew Xin on 8/12/24.

import Foundation
import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
