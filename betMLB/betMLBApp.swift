//  betMLBApp.swift
//  betMLB
//  Created by Andrew Xin on 8/2/24.

import SwiftUI
import SDWebImageSVGCoder

@main
struct betMLB: App {
    init() {
        setUpDependencies() // Initialize SVGCoder
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Initialize SVGCoder
private extension betMLB {
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
