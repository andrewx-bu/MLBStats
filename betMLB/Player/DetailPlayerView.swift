//  DetailPlayerView.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import SwiftUI
import SDWebImageSwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct DetailPlayerView: View {
    var player: Player
    let fetcher = Fetcher()
    @State private var playerImage: Image? = nil
    
    init(players: Player) {
        player = players
        print("initializing detail view for \(player.fullName)")
    }
    
    let columns = [
        GridItem(.flexible(maximum: 75)),
        GridItem(.flexible(maximum: 30)),
        GridItem(.flexible(maximum: 75)),
        GridItem(.flexible(maximum: 30)),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Player Details
            HStack {
                VStack(alignment: .leading, spacing: -4) {
                    Text(player.firstName.uppercased())
                        .font(.title.bold())
                    Text(player.lastName.uppercased())
                        .font(.title.bold())
                    if let num = player.primaryNumber {
                        Text("#\(num) \(player.primaryPosition.name)")
                            .font(.footnote.bold())
                    } else {
                        Text("\(player.primaryPosition.name)")
                    }
                    WebImage(url: URL(string: "https://www.mlbstatic.com/team-logos/\(player.currentTeam).svg"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                .padding(.leading, 5)
                Spacer()
            }
            .border(.red)
            ZStack {
                HStack {
                    Spacer()
                    if let image = playerImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 225, height: 225)
                    } else {
                        WebImage(url: URL(string: "https://www.pngkey.com/png/full/765-7656718_avatar-blank-person.png"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 225, height: 225)
                    }
                }
                .border(.green)
                .padding(.top, -100)
                HStack {
                    VStack(alignment: .leading) {
                        Text("2024")
                            .font(.caption.bold())
                            .padding(.leading, 10)
                        LazyVGrid(columns: columns) {
                            if player.primaryPosition.abbreviation == "P", let pitchingStats = player.pitchingStats {
                                Text("W")
                                    .font(.caption.bold())
                                Text("L")
                                    .font(.caption.bold())
                                Text("ERA")
                                    .font(.caption.bold())
                                Text("BB")
                                    .font(.caption.bold())
                                Text("\(pitchingStats.W)")
                                    .font(.caption.bold())
                                Text("\(pitchingStats.L)")
                                    .font(.caption.bold())
                                Text(String(format: "%.2f", pitchingStats.ERA))
                                    .font(.caption.bold())
                                Text("\(pitchingStats.BB)")
                                    .font(.caption.bold())
                            } else {
                                if let hittingStats = player.hittingStats {
                                    Text("AVG")
                                        .font(.caption.bold())
                                    Text("HR")
                                        .font(.caption.bold())
                                    Text("RBI")
                                        .font(.caption.bold())
                                    Text("R")
                                        .font(.caption.bold())
                                    let decimalString = String(format: "%.3f", hittingStats.AVG)
                                        .split(separator: ".")
                                        .last ?? ""
                                    Text(".\(decimalString)")
                                        .font(.caption.bold())
                                    Text("\(hittingStats.HR)")
                                        .font(.caption.bold())
                                    Text("\(hittingStats.RBI)")
                                        .font(.caption.bold())
                                    Text("\(hittingStats.R)")
                                        .font(.caption.bold())
                                }
                            }
                        }
                    }
                    .border(.indigo)
                    .frame(width: UIScreen.main.bounds.width / 2.5)
                    .padding(.bottom, 40)
                    Spacer()
                }
            }
            Divider()
                .frame(width: 360, height: 2)
                .background(.black)
            Spacer()
        }
        .border(.blue)
        .padding()
        .task {
            await loadPlayerImage()
        }
    }
    
    private func loadPlayerImage() async {
        if let image = await fetcher.fetchPlayerImage(for: player) {
            self.playerImage = image
        }
    }
}

