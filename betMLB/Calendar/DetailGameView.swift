//  DetailGameView.swift
//  betMLB
//  Created by Andrew Xin on 8/14/24.

import SwiftUI

struct DetailGameView: View {
    @State private var game: ScheduleDate.Game
    private let fetcher = Fetcher()
    
    init(detailGame: ScheduleDate.Game) {
        game = detailGame
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
