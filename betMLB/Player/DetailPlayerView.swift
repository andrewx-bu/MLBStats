//  DetailPlayerView.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import SwiftUI
import SDWebImageSwiftUI

struct DetailPlayerView: View {
    @State private var player: Player
    private let fetcher = Fetcher()
    @State private var playerImage: Image? = nil
    @State private var isHitter: Bool = true
    @State private var isPitcher: Bool = false
    @State private var isCatcher: Bool = false
    @State private var hStatsExpanded: Bool = false
    @State private var hBallStatsExpanded: Bool = false
    @State private var hAdvancedStatsExpanded: Bool = false
    @State private var hPlusStatsExpanded: Bool = false
    @State private var pStatsExpanded: Bool = false
    @State private var pBallStatsExpanded: Bool = false
    @State private var p9InnStatsExpanded: Bool = false
    @State private var pAdvancedStatsExpanded: Bool = false
    @State private var pPlusMinusStatsExpanded: Bool = false
    @State private var fStatsExpanded: Bool = false
    @State private var fAdvancedStatsExpanded: Bool = false
    @State private var cStatsExpanded: Bool = false
    
    init(detailPlayer: Player) {
        player = detailPlayer
        if player.primaryPosition.abbreviation == "P" {
            isHitter = false
            isPitcher = true
        } else if player.primaryPosition.abbreviation == "TWP" {
            isPitcher = true
        } else if player.primaryPosition.abbreviation == "C" {
            isCatcher = true
        }
        print("initializing detail view for \(player.fullName)")
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                if let colors = teamColors[mapTeamIdToAbbreviation(fromId: player.currentTeam.id)] {
                    LinearGradient(
                        gradient: Gradient(colors: colors.reversed()),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 390)
                    .opacity(0.75)
                } else {
                    Color.white // Fallback color
                }
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
                            Image.teamLogoImage(for: player.currentTeam.id)
                                .frame(width: 80, height: 80)
                                .padding(.top, 10)
                        }
                        .padding(.leading, 5)
                        Spacer()
                        if let teamColor = teamColors[mapTeamIdToAbbreviation(fromId: player.currentTeam.id)] {
                            Text(player.primaryPosition.abbreviation)
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(width: 45, height: 30)
                                .padding(10)
                                .background(teamColor[1])
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(teamColor[0], lineWidth: 2))
                                .offset(x: -5, y: -50)
                        } else {
                            Text(player.primaryPosition.abbreviation)
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(width: 45, height: 30)
                                .padding(10)
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.red, lineWidth: 2))
                                .offset(x: -5, y: -50)
                        }
                    }
                    ZStack {
                        HStack {
                            Spacer()
                            if let image = playerImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 225, height: 225)
                                    .offset(x: -1)
                            } else {
                                WebImage(url: URL(string: "https://www.pngkey.com/png/full/765-7656718_avatar-blank-person.png"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 225, height: 225)
                                    .offset(y: 11.5)
                            }
                        }
                        .padding(.top, -100)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("2024")
                                    .font(.caption.bold())
                                    .padding(.leading, 10)
                                LazyVGrid(columns: [
                                    GridItem(.flexible(maximum: 75)),
                                    GridItem(.flexible(maximum: 30)),
                                    GridItem(.flexible(maximum: 75)),
                                    GridItem(.flexible(maximum: 30)),
                                ]) {
                                    if isHitter, let hittingStats = player.hittingStats {
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
                                    } else if isPitcher, let pitchingStats = player.pitchingStats {
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
                                    }
                                }
                                .background(
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .frame(width: UIScreen.main.bounds.width / 2.5)
                            .padding(.bottom, 40)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding(.top, 100)
                .padding(.leading, 10)
            }
            if isHitter, let hStats = player.hittingStats {
                
            }
            if isPitcher, let pStats = player.pitchingStats {
                
            }
            if let fStats = player.fieldingStats {
                if isCatcher {
                    
                }
            }
            Section("Player Bio") {
                
            }
        }
        .ignoresSafeArea()
        .padding(.bottom, 15)
        .scrollIndicators(.hidden)
        .task {
            await loadPlayerImage()
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadPlayerImage() async {
        if let image = await fetcher.fetchPlayerImage(for: player) {
            self.playerImage = image
        }
    }
}

