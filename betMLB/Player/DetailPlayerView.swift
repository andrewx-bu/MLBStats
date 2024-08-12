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

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack() {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .padding(.trailing, 25)
    }
}

struct PlusStatItem: View {
    let title: String
    let value: Double?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if let value = value {
                Text(String(format: "%.2f", value))
                    .font(.body)
                    .foregroundColor(color(for: value))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text("N/A")
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 10)
        .padding(.trailing, 25)
    }
    
    private func color(for value: Double) -> Color {
        let average = 100.0
        let deviation = value - average
        
        switch deviation {
        case _ where deviation >= 20:
            return .blue // Considerably better
        case _ where deviation >= 10:
            return .cyan // Better
        case _ where deviation <= -20:
            return .red // Considerably worse
        case _ where deviation <= -10:
            return .yellow // Worse
        default:
            return .purple // Average
        }
    }
}

struct DetailPlayerView: View {
    var player: Player
    let fetcher = Fetcher()
    @State private var playerImage: Image? = nil
    var isHitter: Bool
    var isPitcher: Bool
    var isCatcher: Bool
    var hittingStats: HittingStats?
    var pitchingStats: PitchingStats?
    var fieldingStats: FieldingStats?
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
    
    let columns = [
        GridItem(.flexible(maximum: 75)),
        GridItem(.flexible(maximum: 30)),
        GridItem(.flexible(maximum: 75)),
        GridItem(.flexible(maximum: 30)),
    ]
    
    init(players: Player) {
        player = players
        if let hStats = players.hittingStats {
            hittingStats = hStats
        }
        if let pStats = players.pitchingStats {
            pitchingStats = pStats
        }
        if let fStats = players.fieldingStats {
            fieldingStats = fStats
        }
        switch player.primaryPosition.abbreviation {
        case "P":
            isHitter = false
            isPitcher = true
            isCatcher = false
        case "TWP":
            isHitter = true
            isPitcher = true
            isCatcher = false
        case "C":
            isHitter = true
            isPitcher = false
            isCatcher = true
        default:
            isHitter = true
            isPitcher = false
            isCatcher = false
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
                            WebImage(url: URL(string: "https://www.mlbstatic.com/team-logos/\(player.currentTeam.id).svg"))
                                .resizable()
                                .scaledToFit()
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
                                LazyVGrid(columns: columns) {
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
            if isHitter, let hittingStats = player.hittingStats {
                DisclosureGroup (isExpanded: $hStatsExpanded) {
                    VStack(alignment: .leading) {
                        StatItem(title: "Games Played", value: "\(hittingStats.G)")
                        StatItem(title: "At Bats", value: "\(hittingStats.AB)")
                        StatItem(title: "Plate Appearances", value: "\(hittingStats.PA)")
                        StatItem(title: "Hits", value: "\(hittingStats.H)")
                        StatItem(title: "1B", value: "\(hittingStats.singles)")
                        StatItem(title: "2B", value: "\(hittingStats.doubles)")
                        StatItem(title: "3B", value: "\(hittingStats.triples)")
                        StatItem(title: "Home Runs", value: "\(hittingStats.HR)")
                        StatItem(title: "Runs", value: "\(hittingStats.R)")
                        StatItem(title: "RBI", value: "\(hittingStats.RBI)")
                        StatItem(title: "Walks", value: "\(hittingStats.BB)")
                        StatItem(title: "Intentional Walks", value: "\(hittingStats.IBB)")
                        StatItem(title: "Strikeouts", value: "\(hittingStats.SO)")
                        StatItem(title: "Hit By Pitches", value: "\(hittingStats.HBP)")
                        StatItem(title: "Sacrifice Flies", value: "\(hittingStats.SF)")
                        StatItem(title: "Sacrifice Hits", value: "\(hittingStats.SH)")
                        StatItem(title: "GDP", value: "\(hittingStats.GDP)")
                        StatItem(title: "Stolen Bases", value: "\(hittingStats.SB)")
                        StatItem(title: "Caught Stealing", value: "\(hittingStats.CS)")
                        StatItem(title: "AVG", value: String(format: "%.3f", hittingStats.AVG))
                        StatItem(title: "OBP", value: String(format: "%.3f", hittingStats.OBP))
                        StatItem(title: "SLG", value: String(format: "%.3f", hittingStats.SLG))
                        StatItem(title: "OPS", value: String(format: "%.3f", hittingStats.OPS))
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                } label: {
                    HStack {
                        Text("Hitting Stats")
                            .font(.headline)
                        Spacer()
                        Image(systemName: hStatsExpanded ? "chevron.down" : "chevron.right")
                            .rotationEffect(.degrees(hStatsExpanded ? 180 : 0))
                            .animation(.easeInOut, value: hStatsExpanded)
                            .padding(.trailing, 10)
                    }
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity)
                }
                DisclosureGroup (isExpanded: $hBallStatsExpanded) {
                    VStack(alignment: .leading) {
                        StatItem(title: "Pitches", value: "\(hittingStats.pitches)")
                        StatItem(title: "Balls", value: "\(hittingStats.balls)")
                        StatItem(title: "Strikes", value: "\(hittingStats.strikes)")
                        StatItem(title: "Ground Balls", value: "\(hittingStats.GB)")
                        StatItem(title: "Fly Balls", value: "\(hittingStats.FB)")
                        StatItem(title: "Line Drives", value: "\(hittingStats.LD)")
                        StatItem(title: "Infield Fly Balls", value: "\(hittingStats.IFFB)")
                        StatItem(title: "Infield Hits", value: "\(hittingStats.IFH)")
                        StatItem(title: "Bunts", value: "\(hittingStats.BU)")
                        StatItem(title: "Bunt Hits", value: "\(hittingStats.BUH)")
                        StatItem(title: "GB/FB Ratio", value: String(format: "%.2f", hittingStats.GBperFB))
                        StatItem(title: "Line Drive %", value: String(format: "%.2f", hittingStats.ldPCT))
                        StatItem(title: "Ground Ball %", value: String(format: "%.2f", hittingStats.gbPCT))
                        StatItem(title: "Fly Ball %", value: String(format: "%.2f", hittingStats.fbPCT))
                        StatItem(title: "Infield Fly Ball %", value: String(format: "%.2f", hittingStats.iffpPCT))
                        StatItem(title: "Infield Hit %", value: String(format: "%.2f", hittingStats.ifhPCT))
                        StatItem(title: "Bunt Hit %", value: String(format: "%.2f", hittingStats.buhPCT))
                        StatItem(title: "TTO %", value: hittingStats.ttoPCT != nil ? String(format: "%.2f", hittingStats.ttoPCT!) : "N/A")
                        StatItem(title: "HR/FB Ratio", value: String(format: "%.2f", hittingStats.HRperFB))
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                } label: {
                    HStack {
                        Text("Batted Ball Stats")
                            .font(.headline)
                        Spacer()
                        Image(systemName: hBallStatsExpanded ? "chevron.down" : "chevron.right")
                            .rotationEffect(.degrees(hBallStatsExpanded ? 180 : 0))
                            .animation(.easeInOut, value: hBallStatsExpanded)
                            .padding(.trailing, 10)
                    }
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity)
                }
                DisclosureGroup (isExpanded: $hAdvancedStatsExpanded) {
                    VStack(alignment: .leading) {
                        StatItem(title: "Walk %", value: String(format: "%.2f", hittingStats.bbPCT))
                        StatItem(title: "Strikeout %", value: String(format: "%.2f", hittingStats.kPCT))
                        StatItem(title: "Walks/Strikeouts", value: String(format: "%.2f", hittingStats.BBperK))
                        StatItem(title: "Isolated Power", value: String(format: "%.3f", hittingStats.ISO))
                        StatItem(title: "BABIP", value: String(format: "%.3f", hittingStats.BABIP))
                        StatItem(title: "wOBA", value: String(format: "%.3f", hittingStats.wOBA))
                        StatItem(title: "wRAA", value: String(format: "%.2f", hittingStats.wRAA))
                        StatItem(title: "wRC", value: String(format: "%.2f", hittingStats.wRC))
                        StatItem(title: "WAR", value: String(format: "%.2f", hittingStats.WAR))
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                } label: {
                    HStack {
                        Text("Advanced Hitting Stats")
                            .font(.headline)
                        Spacer()
                        Image(systemName: hAdvancedStatsExpanded ? "chevron.down" : "chevron.right")
                            .rotationEffect(.degrees(hAdvancedStatsExpanded ? 180 : 0))
                            .animation(.easeInOut, value: hAdvancedStatsExpanded)
                            .padding(.trailing, 10)
                    }
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity)
                }
                DisclosureGroup (isExpanded: $hPlusStatsExpanded) {
                    VStack(alignment: .leading) {
                        PlusStatItem(title: "wRC+", value: hittingStats.wRCplus ?? 100)
                        PlusStatItem(title: "AVG+", value: hittingStats.AVGplus ?? 100)
                        PlusStatItem(title: "bbPCT+", value: hittingStats.bbPCTplus ?? 100)
                        PlusStatItem(title: "kPCT+", value: hittingStats.kPCTplus ?? 100)
                        PlusStatItem(title: "OBP+", value: hittingStats.OBPplus ?? 100)
                        PlusStatItem(title: "SLG+", value: hittingStats.SLGplus ?? 100)
                        PlusStatItem(title: "ISO+", value: hittingStats.ISOplus ?? 100)
                        PlusStatItem(title: "BABIP+", value: hittingStats.BABIPplus ?? 100)
                        PlusStatItem(title: "Line Drive %+", value: hittingStats.ldPCTplus ?? 100)
                        PlusStatItem(title: "Ground Ball %+", value: hittingStats.gbPCTplus ?? 100)
                        PlusStatItem(title: "Fly Ball %+", value: hittingStats.fbPCTplus ?? 100)
                        PlusStatItem(title: "HR/FB %+", value: hittingStats.HRperFBpctPLUS ?? 100)
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                } label: {
                    HStack {
                        Text("Hitting Plus Stats")
                            .font(.headline)
                        Spacer()
                        Image(systemName: hPlusStatsExpanded ? "chevron.down" : "chevron.right")
                            .rotationEffect(.degrees(hPlusStatsExpanded ? 180 : 0))
                            .animation(.easeInOut, value: hPlusStatsExpanded)
                            .padding(.trailing, 10)
                    }
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity)
                }
            }
            if isPitcher {
                
            }
            // Fielding Stats
            if isCatcher {
                
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

