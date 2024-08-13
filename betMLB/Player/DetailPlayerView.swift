//  DetailPlayerView.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import SwiftUI
import SDWebImageSwiftUI

struct DetailPlayerView: View {
    @State private var player: Player
    private let fetcher = Fetcher()
    @State private var playerImage: Image? = nil
    @State private var isHitter: Bool
    @State private var isPitcher: Bool
    @State private var isCatcher: Bool
    
    @State private var hittingStatsExpanded: Bool = false
    @State private var hStatsExpanded: Bool = false
    @State private var hBallStatsExpanded: Bool = false
    @State private var hAdvancedStatsExpanded: Bool = false
    @State private var hPlusStatsExpanded: Bool = false
    
    @State private var pitchingStatsExpanded: Bool = false
    @State private var pStatsExpanded: Bool = false
    @State private var pBallStatsExpanded: Bool = false
    @State private var p9InnStatsExpanded: Bool = false
    @State private var pAdvancedStatsExpanded: Bool = false
    @State private var pPlusMinusStatsExpanded: Bool = false
    
    @State private var fieldingStatsExpanded: Bool = false
    @State private var fStatsExpanded: Bool = false
    @State private var fAdvancedStatsExpanded: Bool = false
    @State private var cStatsExpanded: Bool = false
    
    init(detailPlayer: Player) {
        player = detailPlayer
        switch detailPlayer.primaryPosition.abbreviation {
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
                                    if isHitter, let hStats = player.hittingStats {
                                        Text("AVG")
                                            .font(.caption.bold())
                                        Text("HR")
                                            .font(.caption.bold())
                                        Text("RBI")
                                            .font(.caption.bold())
                                        Text("R")
                                            .font(.caption.bold())
                                        let decimalString = String(format: "%.3f", hStats.AVG)
                                            .split(separator: ".")
                                            .last ?? ""
                                        Text(".\(decimalString)")
                                            .font(.caption.bold())
                                        Text("\(hStats.HR)")
                                            .font(.caption.bold())
                                        Text("\(hStats.RBI)")
                                            .font(.caption.bold())
                                        Text("\(hStats.R)")
                                            .font(.caption.bold())
                                    } else if isPitcher, let pStats = player.pitchingStats {
                                        Text("W")
                                            .font(.caption.bold())
                                        Text("L")
                                            .font(.caption.bold())
                                        Text("ERA")
                                            .font(.caption.bold())
                                        Text("BB")
                                            .font(.caption.bold())
                                        Text("\(pStats.W)")
                                            .font(.caption.bold())
                                        Text("\(pStats.L)")
                                            .font(.caption.bold())
                                        Text(String(format: "%.2f", pStats.ERA))
                                            .font(.caption.bold())
                                        Text("\(pStats.BB)")
                                            .font(.caption.bold())
                                    } else {
                                        Text("N/A")
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
            LegendView()
            .padding(.vertical, 20)
            VStack {
                if isHitter == true, let hStats = player.hittingStats {
                    DisclosureGroup(isExpanded: $hittingStatsExpanded) {
                        VStack(spacing: -3) {
                            DisclosureGroup(isExpanded: $hStatsExpanded) {
                                StatItem(title: "Games Played", value: "\(hStats.G)")
                                StatItem(title: "At Bats", value: "\(hStats.AB)")
                                StatItem(title: "Plate Appearances", value: "\(hStats.PA)")
                                StatItem(title: "Hits", value: "\(hStats.H)")
                                StatItem(title: "1B", value: "\(hStats.singles)")
                                StatItem(title: "2B", value: "\(hStats.doubles)")
                                StatItem(title: "3B", value: "\(hStats.triples)")
                                StatItem(title: "Home Runs", value: "\(hStats.HR)")
                                StatItem(title: "Runs", value: "\(hStats.R)")
                                StatItem(title: "RBI", value: "\(hStats.RBI)")
                                StatItem(title: "Walks", value: "\(hStats.BB)")
                                StatItem(title: "Intentional Walks", value: "\(hStats.IBB)")
                                StatItem(title: "Strikeouts", value: "\(hStats.SO)")
                                StatItem(title: "Hit By Pitches", value: "\(hStats.HBP)")
                                StatItem(title: "Sacrifice Flies", value: "\(hStats.SF)")
                                StatItem(title: "Sacrifice Hits", value: "\(hStats.SH)")
                                StatItem(title: "GDP", value: "\(hStats.GDP)")
                                StatItem(title: "Stolen Bases", value: "\(hStats.SB)")
                                StatItem(title: "Caught Stealing", value: "\(hStats.CS)")
                                StatItem(title: "AVG", value: String(format: "%.3f", hStats.AVG))
                                StatItem(title: "OBP", value: String(format: "%.3f", hStats.OBP))
                                StatItem(title: "SLG", value: String(format: "%.3f", hStats.SLG))
                                StatItem(title: "OPS", value: String(format: "%.3f", hStats.OPS))
                            } label: {
                                HStack {
                                    Text("General Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(hStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: hStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $hBallStatsExpanded) {
                                StatItem(title: "Pitches", value: "\(hStats.pitches)")
                                StatItem(title: "Balls", value: "\(hStats.balls)")
                                StatItem(title: "Strikes", value: "\(hStats.strikes)")
                                StatItem(title: "Ground Balls", value: "\(hStats.GB)")
                                StatItem(title: "Fly Balls", value: "\(hStats.FB)")
                                StatItem(title: "Line Drives", value: "\(hStats.LD)")
                                StatItem(title: "Infield Fly Balls", value: "\(hStats.IFFB)")
                                StatItem(title: "Infield Hits", value: "\(hStats.IFH)")
                                StatItem(title: "Bunts", value: "\(hStats.BU)")
                                StatItem(title: "Bunt Hits", value: "\(hStats.BUH)")
                                StatItem(title: "GB/FB Ratio", value: String(format: "%.2f", hStats.GBperFB))
                                StatItem(title: "Line Drive %", value: String(format: "%.2f", hStats.ldPCT))
                                StatItem(title: "Ground Ball %", value: String(format: "%.2f", hStats.gbPCT))
                                StatItem(title: "Fly Ball %", value: String(format: "%.2f", hStats.fbPCT))
                                StatItem(title: "Infield Fly Ball %", value: String(format: "%.2f", hStats.iffpPCT))
                                StatItem(title: "Infield Hit %", value: String(format: "%.2f", hStats.ifhPCT))
                                StatItem(title: "Bunt Hit %", value: String(format: "%.2f", hStats.buhPCT))
                                StatItem(title: "Three Total Outcomes %", value: hStats.ttoPCT != nil ? String(format: "%.2f", hStats.ttoPCT!) : "N/A")
                                StatItem(title: "HR/FB Ratio", value: String(format: "%.2f", hStats.HRperFB))
                            } label: {
                                HStack {
                                    Text("Batted Ball Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(hBallStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: hBallStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $hAdvancedStatsExpanded) {
                                StatItem(title: "BB%", value: String(format: "%.2f", hStats.bbPCT))
                                StatItem(title: "K%", value: String(format: "%.2f", hStats.kPCT))
                                StatItem(title: "BB/K", value: String(format: "%.2f", hStats.BBperK))
                                StatItem(title: "ISO", value: String(format: "%.3f", hStats.ISO))
                                StatItem(title: "BABIP", value: String(format: "%.3f", hStats.BABIP))
                                StatItem(title: "wOBA", value: String(format: "%.3f", hStats.wOBA))
                                StatItem(title: "wRAA", value: String(format: "%.2f", hStats.wRAA))
                                StatItem(title: "wRC", value: String(format: "%.2f", hStats.wRC))
                                StatItem(title: "WAR", value: String(format: "%.2f", hStats.WAR))
                            } label: {
                                HStack {
                                    Text("Advanced Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(hAdvancedStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: hAdvancedStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $hPlusStatsExpanded) {
                                PlusStatItem(title: "wRC+", value: hStats.wRCplus ?? nil)
                                PlusStatItem(title: "AVG+", value: hStats.AVGplus ?? nil)
                                PlusStatItem(title: "BB%+", value: hStats.bbPCTplus ?? nil)
                                MinusStatItem(title: "K%+", value: hStats.kPCTplus ?? nil)
                                PlusStatItem(title: "OBP+", value: hStats.OBPplus ?? nil)
                                PlusStatItem(title: "SLG+", value: hStats.SLGplus ?? nil)
                                PlusStatItem(title: "ISO+", value: hStats.ISOplus ?? nil)
                                PlusStatItem(title: "BABIP+", value: hStats.BABIPplus ?? nil)
                                PlusStatItem(title: "LD%+", value: hStats.ldPCTplus ?? nil)
                                StatItem(title: "GB%+", value: hStats.gbPCTplus != nil ? String(format: "%.2f", hStats.gbPCTplus!) : "N/A")
                                StatItem(title: "FB%+", value: hStats.fbPCTplus != nil ? String(format: "%.2f", hStats.fbPCTplus!) : "N/A")
                                PlusStatItem(title: "HR/FB%+", value: hStats.HRperFBpctPLUS ?? nil)
                            } label: {
                                HStack {
                                    Text("Plus Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(hPlusStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: hPlusStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.leading, 10)
                    } label: {
                        HStack {
                            Text("Hitting Stats")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15))
                                .rotationEffect(.degrees(hittingStatsExpanded ? 90 : 0))
                                .animation(.easeInOut, value: hittingStatsExpanded)
                                .buttonStyle(.plain)
                        }
                    }
                }
                if isPitcher, let pStats = player.pitchingStats {
                    DisclosureGroup(isExpanded: $pitchingStatsExpanded) {
                        VStack(spacing: -3) {
                            DisclosureGroup(isExpanded: $pStatsExpanded) {
                                StatItem(title: "Wins", value: "\(pStats.W)")
                                StatItem(title: "Losses", value: "\(pStats.L)")
                                StatItem(title: "ERA", value: String(format: "%.3f", pStats.ERA))
                                StatItem(title: "WHIP", value: String(format: "%.3f", pStats.WHIP))
                                StatItem(title: "Games Played", value: "\(pStats.G)")
                                StatItem(title: "Games Started", value: "\(pStats.GS)")
                                StatItem(title: "Saves", value: "\(pStats.SV)")
                                StatItem(title: "Holds", value: "\(pStats.HLD)")
                                StatItem(title: "Blown Saves", value: "\(pStats.BS)")
                                StatItem(title: "Innings Pitched", value: String(format: "%.1f", pStats.IP))
                                StatItem(title: "Total Batters Faced", value: "\(pStats.TBF)")
                                StatItem(title: "Hits", value: "\(pStats.H)")
                                StatItem(title: "Runs", value: "\(pStats.R)")
                                StatItem(title: "Earned Runs", value: "\(pStats.ER)")
                                StatItem(title: "Home Runs", value: "\(pStats.HR)")
                                StatItem(title: "Walks", value: "\(pStats.BB)")
                                StatItem(title: "Intentional Walks", value: "\(pStats.IBB)")
                                StatItem(title: "Hit By Pitches", value: "\(pStats.HBP)")
                                StatItem(title: "Wild Pitches", value: "\(pStats.WP)")
                                StatItem(title: "Strikeouts", value: "\(pStats.SO)")
                                StatItem(title: "AVG", value: String(format: "%.3f", pStats.AVG))
                            } label: {
                                HStack {
                                    Text("General Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(pStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: pStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $pBallStatsExpanded) {
                                StatItem(title: "Pitches", value: "\(pStats.pitches)")
                                StatItem(title: "Balls", value: "\(pStats.balls)")
                                StatItem(title: "Strikes", value: "\(pStats.strikes)")
                                StatItem(title: "Ground Balls", value: "\(pStats.GB)")
                                StatItem(title: "Fly Balls", value: "\(pStats.FB)")
                                StatItem(title: "Line Drives", value: "\(pStats.LD)")
                                StatItem(title: "Infield Fly Balls", value: "\(pStats.IFFB)")
                                StatItem(title: "Infield Hits", value: "\(pStats.IFH)")
                                StatItem(title: "Bunts", value: "\(pStats.BU)")
                                StatItem(title: "Bunt Hits", value: "\(pStats.BUH)")
                                StatItem(title: "GB/FB Ratio", value: String(format: "%.2f", pStats.GBperFB))
                                StatItem(title: "Line Drive %", value: String(format: "%.2f", pStats.ldPCT))
                                StatItem(title: "Ground Ball %", value: String(format: "%.2f", pStats.gbPCT))
                                StatItem(title: "Fly Ball %", value: String(format: "%.2f", pStats.fbPCT))
                                StatItem(title: "Infield Fly Ball %", value: String(format: "%.2f", pStats.iffbPCT))
                                StatItem(title: "Infield Hit %", value: String(format: "%.2f", pStats.ifhPCT))
                                StatItem(title: "Bunt Hit %", value: String(format: "%.2f", pStats.buhPCT))
                                StatItem(title: "Three Total Outcomes %", value: String(format: "%.2f", pStats.ttoPCT))
                                StatItem(title: "HR/FB Ratio", value: String(format: "%.2f", pStats.HRperFB))
                            } label: {
                                HStack {
                                    Text("Pitched Ball Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(pBallStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: pBallStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $p9InnStatsExpanded) {
                                StatItem(title: "K/9", value: String(format: "%.2f", pStats.Kper9))
                                StatItem(title: "BB/9", value: String(format: "%.2f", pStats.BBper9))
                                StatItem(title: "H/9", value: String(format: "%.2f", pStats.Hper9))
                                StatItem(title: "HR/9", value: String(format: "%.2f", pStats.HRper9))
                                StatItem(title: "RS/9", value: String(format: "%.2f", pStats.RSper9))
                            } label: {
                                HStack {
                                    Text("Per 9 Inning Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(p9InnStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: p9InnStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $pAdvancedStatsExpanded) {
                                StatItem(title: "BABIP", value: String(format: "%.3f", pStats.BABIP))
                                StatItem(title: "K/BB", value: String(format: "%.2f", pStats.KperBB ?? 0))
                                StatItem(title: "K%", value: String(format: "%.2f", pStats.kPCT))
                                StatItem(title: "BB%", value: String(format: "%.2f", pStats.bbPCT))
                                StatItem(title: "LOB%", value: String(format: "%.2f", pStats.lobPCT))
                                StatItem(title: "Run Support", value: "\(pStats.RS)")
                                StatItem(title: "SIERA", value: String(format: "%.2f", pStats.SIERA ?? 0))
                                StatItem(title: "FIP", value: String(format: "%.2f", pStats.FIP))
                                StatItem(title: "xFIP", value: String(format: "%.2f", pStats.xFIP))
                                StatItem(title: "kwERA", value: String(format: "%.2f", pStats.kwERA))
                                StatItem(title: "tERA", value: String(format: "%.2f", pStats.tERA))
                                StatItem(title: "WAR", value: String(format: "%.2f", pStats.WAR))
                            } label: {
                                HStack {
                                    Text("Advanced Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(pAdvancedStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: pAdvancedStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $pPlusMinusStatsExpanded) {
                                MinusStatItem(title: "ERA-", value: pStats.ERAminus)
                                MinusStatItem(title: "FIP-", value: pStats.FIPminus)
                                MinusStatItem(title: "xFIP-", value: pStats.xFIPminus)
                                PlusStatItem(title: "K/9+", value: pStats.Kper9plus)
                                MinusStatItem(title: "BB/9+", value: pStats.BBper9plus)
                                PlusStatItem(title: "K/BB+", value: pStats.KperBBplus)
                                MinusStatItem(title: "H/9+", value: pStats.Hper9plus)
                                MinusStatItem(title: "HR/9+", value: pStats.HRper9plus)
                                MinusStatItem(title: "AVG+", value: pStats.AVGplus)
                                MinusStatItem(title: "WHIP+", value: pStats.WHIPplus)
                                MinusStatItem(title: "BABIP+", value: pStats.BABIPplus)
                                MinusStatItem(title: "LOB%+", value: pStats.lobPCTplus)
                                PlusStatItem(title: "K%+", value: pStats.kPCTplus)
                                MinusStatItem(title: "BB%+", value: pStats.bbPCTplus)
                                MinusStatItem(title: "LD%+", value: pStats.ldPCTplus)
                                StatItem(title: "GB%+", value: pStats.gbPCTplus != nil ? String(format: "%.2f", pStats.gbPCTplus!) : "N/A")
                                StatItem(title: "FB%+", value: pStats.fbPCTplus != nil ? String(format: "%.2f", pStats.fbPCTplus!) : "N/A")
                                MinusStatItem(title: "HR/FB%+", value: pStats.HRperFBpctPLUS)
                            } label: {
                                HStack {
                                    Text("Plus Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(pPlusMinusStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: pPlusMinusStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.leading, 10)
                    } label: {
                        HStack {
                            Text("Pitching Stats")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15))
                                .rotationEffect(.degrees(pitchingStatsExpanded ? 90 : 0))
                                .animation(.easeInOut, value: pitchingStatsExpanded)
                                .buttonStyle(.plain)
                        }
                    }
                }
                if let fStats = player.fieldingStats {
                    DisclosureGroup(isExpanded: $fieldingStatsExpanded) {
                        VStack(spacing: -3) {
                            DisclosureGroup(isExpanded: $fStatsExpanded) {
                                StatItem(title: "Games Played", value: "\(fStats.G)")
                                StatItem(title: "Innings Played", value: String(format: "%.2f", fStats.inn))
                                StatItem(title: "Putouts", value: "\(fStats.PO)")
                                StatItem(title: "Assists", value: "\(fStats.A)")
                                StatItem(title: "Errors", value: "\(fStats.E)")
                                StatItem(title: "Double Plays", value: "\(fStats.DP)")
                                StatItem(title: "Fielding %", value: String(format: "%.3f", fStats.FP))
                            } label: {
                                HStack {
                                    Text("General Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(fStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: fStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            DisclosureGroup(isExpanded: $fAdvancedStatsExpanded) {
                                if let drs = fStats.DRS {
                                    StatItem(title: "Defensive Runs Saved", value: "\(drs)")
                                }
                                if let uzr = fStats.UZR {
                                    StatItem(title: "Ultimate Zone Rating", value: String(format: "%.2f", uzr))
                                }
                                if let uzrPer150 = fStats.UZRper150 {
                                    StatItem(title: "UZR per 150 Games", value: String(format: "%.2f", uzrPer150))
                                }
                                if let def = fStats.DEF {
                                    StatItem(title: "Defensive Runs Above AVG", value: String(format: "%.2f", def))
                                }
                                if let oaa = fStats.OAA {
                                    StatItem(title: "Outs Above AVG", value: "\(oaa)")
                                }
                                if let frv = fStats.FRV {
                                    StatItem(title: "Fielding Run Value", value: "\(frv)")
                                }
                            } label: {
                                HStack {
                                    Text("Advanced Stats")
                                        .font(.callout)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .rotationEffect(.degrees(fAdvancedStatsExpanded ? 90 : 0))
                                        .animation(.easeInOut, value: fAdvancedStatsExpanded)
                                        .buttonStyle(.plain)
                                }
                            }
                            if isCatcher {
                                DisclosureGroup(isExpanded: $cStatsExpanded) {
                                    if let sb = fStats.SB {
                                        StatItem(title: "Stolen Bases", value: "\(sb)")
                                    }
                                    if let cs = fStats.CS {
                                        StatItem(title: "Caught Stealing", value: "\(cs)")
                                    }
                                    if let pb = fStats.PB {
                                        StatItem(title: "Passed Balls", value: "\(pb)")
                                    }
                                    if let wp = fStats.WP {
                                        StatItem(title: "Wild Pitches", value: "\(wp)")
                                    }
                                    if let frm = fStats.FRM {
                                        StatItem(title: "Catcher Framing", value: String(format: "%.2f", frm))
                                    }
                                } label: {
                                    HStack {
                                        Text("Catching Stats")
                                            .font(.callout)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10))
                                            .rotationEffect(.degrees(cStatsExpanded ? 90 : 0))
                                            .animation(.easeInOut, value: cStatsExpanded)
                                            .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.leading, 10)
                    } label: {
                        HStack {
                            Text("Fielding Stats")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15))
                                .rotationEffect(.degrees(fieldingStatsExpanded ? 90 : 0))
                                .animation(.easeInOut, value: fieldingStatsExpanded)
                                .buttonStyle(.plain)
                        }
                    }
                }
            }
            .foregroundStyle(.white, .clear)
            .padding(.leading, 10)
            .padding(.bottom, 10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            Section("Player Bio") {
                
            }
        }
        .ignoresSafeArea()
        .padding(.bottom, 25)
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
