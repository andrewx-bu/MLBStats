//  DetailGameView.swift
//  betMLB
//  Created by Andrew Xin on 8/14/24.

import SwiftUI

struct DetailGameView: View {
    @State private var game: ScheduleDate.Game
    private let fetcher = Fetcher()
    private let dictionaryMaker = DictionaryMaker()
    @State private var lineupData: LineupData? = nil
    @State private var lineScore: LineScore? = nil
    @State private var players: [SimplePlayer] = []
    @State private var hittingStatsDictionary: HittingStatsDictionary = [:]
    @State private var pitchingStatsDictionary: PitchingStatsDictionary = [:]
    @State private var fieldingStatsDictionary: FieldingStatsDictionary = [:]
    @State private var inProgress = false
    @State private var isFinished = false
    @State private var scheduled = true
    @State private var playerImages: [Int: Image] = [:]
    @State private var morePitcherStatsExpanded = false
    
    init(detailGame: ScheduleDate.Game) {
        game = detailGame
        if game.status.detailedState == "In Progress" {
            inProgress = true
        } else if game.status.detailedState == "Final" {
            isFinished = true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let awayColors = teamColors[mapTeamIdToAbbreviation(fromId: game.teams.away.team.id)], let homeColors = teamColors[mapTeamIdToAbbreviation(fromId: game.teams.home.team.id)] {
                VStack(alignment: .leading) {
                    Text("\(game.teams.away.team.name) @ \(game.teams.home.team.name) (\(game.venue.name))")
                    let startTime = game.gameDate.formattedGameTime()
                    switch game.status.detailedState {
                    case "Final":
                        Text("Status: Final, started at \(startTime)")
                    case "Scheduled":
                        Text("Status: Scheduled, to start at \(startTime)")
                    case "In Progress":
                        Text("Status: In Progress, started at \(startTime)")
                    default:
                        Text("Status: \(game.status.detailedState), start at \(startTime)")
                    }
                    Text("Game ID: \(game.gamePk)")
                }
                HStack {
                    if let score = game.teams.away.score {
                        Spacer()
                        Text("\(score)")
                            .font(.title)
                            .fontWeight((game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? .bold : .regular)
                            .foregroundColor((game.teams.away.score ?? 0) < (game.teams.home.score ?? 0) ? .black : .primary)
                    }
                    Spacer()
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(awayColors[1].opacity(0.7))
                        .overlay(
                            Image.teamLogoImage(for: game.teams.away.team.id)
                                .frame(width: 25, height: 25)
                        )
                    VStack {
                        Text("\(mapTeamIdToAbbreviation(fromId: game.teams.away.team.id))")
                            .font(.callout)
                        Text("\(game.teams.away.leagueRecord.wins)-\(game.teams.away.leagueRecord.losses)")
                            .font(.caption2)
                    }
                    .fontWeight((game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? .bold : .regular)
                    .foregroundColor((game.teams.away.score ?? 0) < (game.teams.home.score ?? 0) ? .black : .primary)
                    Spacer()
                    Text("\(game.gameDate.formattedGameTime())")
                    Spacer()
                    VStack {
                        Text("\(mapTeamIdToAbbreviation(fromId: game.teams.home.team.id))")
                            .font(.callout)
                        Text("\(game.teams.home.leagueRecord.wins)-\(game.teams.home.leagueRecord.losses)")
                            .font(.caption2)
                    }
                    .fontWeight((game.teams.away.score ?? 0) < (game.teams.home.score ?? 0) ? .bold : .regular)
                    .foregroundColor((game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? .black : .primary)
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(homeColors[1].opacity(0.7))
                        .overlay(
                            Image.teamLogoImage(for: game.teams.home.team.id)
                                .frame(width: 25, height: 25)
                        )
                    Spacer()
                    if let score = game.teams.home.score {
                        Text("\(score)")
                            .font(.title)
                            .fontWeight((game.teams.away.score ?? 0) < (game.teams.home.score ?? 0) ? .bold : .regular)
                            .foregroundColor((game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? .black : .primary)
                        Spacer()
                    }
                }
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: (game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? awayColors : homeColors),
                            startPoint: (game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? .leading : .trailing,
                            endPoint: (game.teams.away.score ?? 0) > (game.teams.home.score ?? 0) ? .trailing : .leading
                        )
                            .opacity(1.0)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
        }
        .font(.footnote)
        .padding(.horizontal, 10)
        // Probable Pitchers
        VStack(alignment: .leading) {
            Text("Probable Pitchers")
                .font(.headline)
            Divider()
                .frame(width: 175, height: 3)
                .background(.indigo)
            HStack() {
                Image.teamLogoImage(for: game.teams.away.team.id)
                    .frame(width: 20, height: 20)
                Text("\(mapTeamIdToAbbreviation(fromId: game.teams.away.team.id))")
                    .font(.footnote)
                Spacer()
                Text("Pitchers")
                    .font(.callout.bold())
                Spacer()
                Text("\(mapTeamIdToAbbreviation(fromId: game.teams.home.team.id))")
                    .font(.footnote)
                Image.teamLogoImage(for: game.teams.home.team.id)
                    .frame(width: 20, height: 20)
            }
            .frame(maxWidth: .infinity)
            HStack {
                if let lineupData = self.lineupData {
                    Spacer()
                    if let firstPitcherID = lineupData.awayStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        VStack {
                            Text("\(pitcher.person.fullName.abbreviatedName)")
                            Text("#\(pitcher.jerseyNumber)")
                                .font(.caption)
                        }
                        if let image = playerImages[firstPitcherID] {
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1.5)
                                )
                        } else {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                                .overlay(
                                    Text("?")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                )
                        }
                    } else {
                        Text("(Not found)")
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    Text("vs")
                    if let firstPitcherID = lineupData.homeStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let image = playerImages[firstPitcherID] {
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1.5)
                                )
                        } else {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                                .overlay(
                                    Text("?")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                )
                        }
                        VStack {
                            Text("\(pitcher.person.fullName.abbreviatedName)")
                            Text("#\(pitcher.jerseyNumber)")
                                .font(.caption)
                        }
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                        Text("(Not found)")
                    }
                    Spacer()
                }
            }
            .font(.footnote)
            Divider()
            HStack {
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.awayStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text("\(pitchingStats.W)-\(pitchingStats.L)")
                        }
                    } else {
                        Text("N/A")
                    }
                }
                Spacer()
                Text("W-L")
                Spacer()
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.homeStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text("\(pitchingStats.W)-\(pitchingStats.L)")
                        }
                    } else {
                        Text("N/A")
                    }
                }
            }
            .font(.footnote)
            Divider()
            HStack {
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.awayStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text(String(format: "%.3f", pitchingStats.ERA))
                        }
                    } else {
                        Text("N/A")
                    }
                }
                Spacer()
                Text("ERA")
                Spacer()
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.homeStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text(String(format: "%.3f", pitchingStats.ERA))
                        }
                    } else {
                        Text("N/A")
                    }
                }
            }
            .font(.footnote)
            Divider()
            HStack {
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.awayStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text(String(format: "%.3f", pitchingStats.WHIP))
                        }
                    } else {
                        Text("N/A")
                    }
                }
                Spacer()
                Text("WHIP")
                Spacer()
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.homeStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text(String(format: "%.3f", pitchingStats.WHIP))
                        }
                    } else {
                        Text("N/A")
                    }
                }
            }
            .font(.footnote)
            Divider()
            HStack {
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.awayStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text(String(format: "%.1f", pitchingStats.IP))
                        }
                    } else {
                        Text("N/A")
                    }
                }
                Spacer()
                Text("IP")
                Spacer()
                if let lineupData = self.lineupData {
                    if let firstPitcherID = lineupData.homeStartingPitchers.first,
                       let pitcher = findPlayer(by: firstPitcherID) {
                        if let pitchingStats = pitcher.pitchingStats {
                            Text(String(format: "%.1f", pitchingStats.IP))
                        }
                    } else {
                        Text("N/A")
                    }
                }
            }
            .font(.footnote)
            Divider()
            DisclosureGroup(isExpanded: $morePitcherStatsExpanded) {
                VStack {
                    HStack {
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.awayStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.H)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                        Spacer()
                        Text("H")
                        Spacer()
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.homeStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.H)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                    }
                    Divider()
                    HStack {
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.awayStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.strikes)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                        Spacer()
                        Text("K")
                        Spacer()
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.homeStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.strikes)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                    }
                    Divider()
                    HStack {
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.awayStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.BB)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                        Spacer()
                        Text("BB")
                        Spacer()
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.homeStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.BB)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                    }
                    Divider()
                    HStack {
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.awayStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.HR)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                        Spacer()
                        Text("HR")
                        Spacer()
                        if let lineupData = self.lineupData {
                            if let firstPitcherID = lineupData.homeStartingPitchers.first,
                               let pitcher = findPlayer(by: firstPitcherID) {
                                if let pitchingStats = pitcher.pitchingStats {
                                    Text("\(pitchingStats.HR)")
                                }
                            } else {
                                Text("N/A")
                            }
                        }
                    }
                }
                .font(.footnote)
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .rotationEffect(.degrees(morePitcherStatsExpanded ? 90 : 0))
                        .animation(.easeInOut, value: morePitcherStatsExpanded)
                        .foregroundStyle(.gray)
                    Text("Show More")
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .font(.footnote)
            }
            .animation(.easeInOut, value: morePitcherStatsExpanded)
            .foregroundStyle(.white, .clear)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
        )
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        // Batting Leaders
        VStack(alignment: .leading) {
            Text("Batting Leaders")
                .font(.headline)
            Divider()
                .frame(width: 175, height: 3)
                .background(.indigo)
            HStack() {
                Image.teamLogoImage(for: game.teams.away.team.id)
                    .frame(width: 20, height: 20)
                Text("\(mapTeamIdToAbbreviation(fromId: game.teams.away.team.id))")
                    .font(.footnote)
                Spacer()
                Text("\(mapTeamIdToAbbreviation(fromId: game.teams.home.team.id))")
                    .font(.footnote)
                Image.teamLogoImage(for: game.teams.home.team.id)
                    .frame(width: 20, height: 20)
            }
            .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                Text("Home Runs")
                    .font(.footnote)
                Spacer()
            }
            HStack {
                if let lineupData = self.lineupData {
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let topAwayBatter = findTopHitter(by: .HR, from: lineupData.awayBatters), let hittingStats = topAwayBatter.hittingStats {
                            let decimalString = String(format: "%.3f", hittingStats.AVG)
                                .split(separator: ".")
                                .last ?? ""
                            Text("\(topAwayBatter.person.fullName.abbreviatedName)")
                                .font(.caption2)
                            Text("\(hittingStats.HR)")
                                .fontWeight(.bold) +
                            Text(" HR ") +
                            Text(".\(decimalString)")
                                .fontWeight(.bold) +
                            Text(" AVG ") +
                            Text("\(hittingStats.RBI)")
                                .fontWeight(.bold) +
                            Text(" RBI")
                        } else {
                            Text("(Not Found)")
                                .font(.caption)
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 8))
                    if let topAwayBatter = findTopHitter(by: .HR, from: lineupData.awayBatters), let image = playerImages[topAwayBatter.person.id] {
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    if let topHomeBatter = findTopHitter(by: .HR, from: lineupData.homeBatters), let image = playerImages[topHomeBatter.person.id] {
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    VStack(alignment: .leading) {
                        if let topHomeBatter = findTopHitter(by: .HR, from: lineupData.homeBatters), let hittingStats = topHomeBatter.hittingStats {
                            let decimalString = String(format: "%.3f", hittingStats.AVG)
                                .split(separator: ".")
                                .last ?? ""
                            Text("\(topHomeBatter.person.fullName.abbreviatedName)")
                                .font(.caption2)
                            Text("\(hittingStats.HR)")
                                .fontWeight(.bold) +
                            Text(" HR ") +
                            Text(".\(decimalString)")
                                .fontWeight(.bold) +
                            Text(" AVG ") +
                            Text("\(hittingStats.RBI)")
                                .fontWeight(.bold) +
                            Text(" RBI")
                        } else {
                            Text("(Not Found)")
                                .font(.caption)
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 9))
                    Spacer()
                }
            }
            Divider()
            HStack {
                Spacer()
                Text("Batting Average")
                    .font(.footnote)
                Spacer()
            }
            HStack {
                if let lineupData = self.lineupData {
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let topAwayBatter = findTopHitter(by: .AVG, from: lineupData.awayBatters), let hittingStats = topAwayBatter.hittingStats {
                            let AVG = String(format: "%.3f", hittingStats.AVG)
                                .split(separator: ".")
                                .last ?? ""
                            let OBP = String(format: "%.3f", hittingStats.OBP)
                                .split(separator: ".")
                                .last ?? ""
                            let SLG = String(format: "%.3f", hittingStats.SLG)
                                .split(separator: ".")
                                .last ?? ""
                            Text("\(topAwayBatter.person.fullName.abbreviatedName)")
                                .font(.caption2)
                            Text(".\(AVG)")
                                .fontWeight(.bold) +
                            Text(" AVG ") +
                            Text(".\(OBP)")
                                .fontWeight(.bold) +
                            Text(" OBP ")
                            Text(".\(SLG)")
                                .fontWeight(.bold) +
                            Text(" SLG")
                        } else {
                            Text("(Not Found)")
                                .font(.caption)
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 8))
                    if let topAwayBatter = findTopHitter(by: .AVG, from: lineupData.awayBatters), let image = playerImages[topAwayBatter.person.id] {
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    if let topHomeBatter = findTopHitter(by: .AVG, from: lineupData.homeBatters), let image = playerImages[topHomeBatter.person.id] {
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    VStack(alignment: .leading) {
                        if let topAwayBatter = findTopHitter(by: .AVG, from: lineupData.homeBatters), let hittingStats = topAwayBatter.hittingStats {
                            let AVG = String(format: "%.3f", hittingStats.AVG)
                                .split(separator: ".")
                                .last ?? ""
                            let OBP = String(format: "%.3f", hittingStats.OBP)
                                .split(separator: ".")
                                .last ?? ""
                            let SLG = String(format: "%.3f", hittingStats.SLG)
                                .split(separator: ".")
                                .last ?? ""
                            Text("\(topAwayBatter.person.fullName.abbreviatedName)")
                                .font(.caption2)
                            Text(".\(AVG)")
                                .fontWeight(.bold) +
                            Text(" AVG ") +
                            Text(".\(OBP)")
                                .fontWeight(.bold) +
                            Text(" OBP ")
                            Text(".\(SLG)")
                                .fontWeight(.bold) +
                            Text(" SLG")
                        } else {
                            Text("(Not Found)")
                                .font(.caption)
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 9))
                    Spacer()
                }
            }
            Divider()
            HStack {
                Spacer()
                Text("Runs Batted In")
                    .font(.footnote)
                Spacer()
            }
            HStack {
                if let lineupData = self.lineupData {
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let topAwayBatter = findTopHitter(by: .RBI, from: lineupData.awayBatters), let hittingStats = topAwayBatter.hittingStats {
                            let decimalString = String(format: "%.3f", hittingStats.AVG)
                                .split(separator: ".")
                                .last ?? ""
                            Text("\(topAwayBatter.person.fullName.abbreviatedName)")
                                .font(.caption2)
                            Text("\(hittingStats.RBI)")
                                .fontWeight(.bold) +
                            Text(" RBI") +
                            Text(".\(decimalString)")
                                .fontWeight(.bold) +
                            Text(" AVG ") +
                            Text("\(hittingStats.HR)")
                                .fontWeight(.bold) +
                            Text(" HR ")
                        } else {
                            Text("(Not Found)")
                                .font(.caption)
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 8))
                    if let topAwayBatter = findTopHitter(by: .RBI, from: lineupData.awayBatters), let image = playerImages[topAwayBatter.person.id] {
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    if let topHomeBatter = findTopHitter(by: .RBI, from: lineupData.homeBatters), let image = playerImages[topHomeBatter.person.id] {
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .overlay(
                                Text("?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    VStack(alignment: .leading) {
                        if let topHomeBatter = findTopHitter(by: .RBI, from: lineupData.homeBatters), let hittingStats = topHomeBatter.hittingStats {
                            let decimalString = String(format: "%.3f", hittingStats.AVG)
                                .split(separator: ".")
                                .last ?? ""
                            Text("\(topHomeBatter.person.fullName.abbreviatedName)")
                                .font(.caption2)
                            Text("\(hittingStats.RBI)")
                                .fontWeight(.bold) +
                            Text(" RBI") +
                            Text(".\(decimalString)")
                                .fontWeight(.bold) +
                            Text(" AVG ") +
                            Text("\(hittingStats.HR)")
                                .fontWeight(.bold) +
                            Text(" HR ")
                        } else {
                            Text("(Not Found)")
                                .font(.caption)
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 9))
                    Spacer()
                }
            }
            Divider()
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        // Team Stats
        VStack(alignment: .leading) {
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemGray6))
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .task {
            await loadData()
        }
    }
    
    
    // Fetches both teams rosters and starting lineups
    private func loadData() async {
        do {
            await loadLineupsAndLineScore()
            async let fetchedAwayPlayers = fetcher.fetchSimplePlayers(teamId: self.game.teams.away.team.id)
            async let fetchedHomePlayers = fetcher.fetchSimplePlayers(teamId: self.game.teams.home.team.id)
            
            async let fetchedHittingStats: [HittingStats] = fetcher.fetchStats(statType: .hitting)
            async let fetchedPitchingStats: [PitchingStats] = fetcher.fetchStats(statType: .pitching)
            async let fetchedFieldingStats: [FieldingStats] = fetcher.fetchStats(statType: .fielding)
            
            let allPlayers = try await fetchedAwayPlayers + fetchedHomePlayers
            let hittingStats = try await fetchedHittingStats
            let pitchingStats = try await fetchedPitchingStats
            let fieldingStats = try await fetchedFieldingStats
            
            self.players = allPlayers
            let hittingStatsDictionary = dictionaryMaker.makePlayerHittingDictionary(hittingStats: hittingStats)
            let pitchingStatsDictionary = dictionaryMaker.makePlayerPitchingDictionary(pitchingStats: pitchingStats)
            let fieldingStatsDictionary = dictionaryMaker.makePlayerFieldingDictionary(fieldingStats: fieldingStats)
            
            updatePlayersWithStats(hittingStatsDictionary: hittingStatsDictionary, pitchingStatsDictionary: pitchingStatsDictionary, fieldingStatsDictionary: fieldingStatsDictionary)
            
            await loadPlayerImages()
        } catch {
            print("loadData: Error fetching data")
        }
    }
    
    private func loadLineupsAndLineScore() async {
        do {
            self.lineupData = try await fetcher.fetchLineups(gamePk: self.game.gamePk)
            self.lineScore = try await fetcher.fetchLineScore(gamePk: self.game.gamePk)
        } catch {
            print("loadLineupsAndLineScore: Error fetching data")
        }
    }
    
    // Populate player's hitting/pitching/fieldingStats
    private func updatePlayersWithStats(hittingStatsDictionary: HittingStatsDictionary, pitchingStatsDictionary: PitchingStatsDictionary, fieldingStatsDictionary: FieldingStatsDictionary
    ) {
        players = players.map { player in
            var updatedPlayer = player
            
            // Match player with his stats
            if let hitting = hittingStatsDictionary[player.person.id] {
                updatedPlayer.hittingStats = hitting
                // Extract fangraphs id for getting headshot later
                updatedPlayer.headshotId = hitting.playerid
            }
            
            if let pitching = pitchingStatsDictionary[player.person.id] {
                updatedPlayer.pitchingStats = pitching
                updatedPlayer.headshotId = pitching.playerid
            }
            
            if let fielding = fieldingStatsDictionary[player.person.id] {
                updatedPlayer.fieldingStats = fielding
                updatedPlayer.headshotId = fielding.playerid
            }
            
            return updatedPlayer
        }
    }
    
    private func findPlayer(by id: Int) -> SimplePlayer? {
        return players.first { $0.person.id == id }
    }
    
    private func loadPlayerImages() async {
        await withTaskGroup(of: (Int, Image?).self) { group in
            for player in players {
                group.addTask {
                    let image = await fetcher.fetchPlayerImages(for: player)
                    return (player.person.id, image)
                }
            }
            
            for await (playerId, image) in group {
                if let image = image {
                    self.playerImages[playerId] = image
                }
            }
        }
    }
    
    enum StatType {
        case HR, AVG, RBI
        
        var keyPath: PartialKeyPath<HittingStats> {
            switch self {
            case .HR:
                return \.HR
            case .AVG:
                return \.AVG
            case .RBI:
                return \.RBI
            }
        }
        
        var valueType: Any.Type {
            switch self {
            case .HR, .RBI:
                return Int.self
            case .AVG:
                return Double.self
            }
        }
    }

    func findTopHitter(by statType: StatType, from batterIds: [Int]) -> SimplePlayer? {
        // Convert IDs to players
        let playersList = batterIds.compactMap { findPlayer(by: $0) }
        
        // Find the player with the highest value for the specified stat type
        return playersList.max { (player1, player2) in
            let stat1 = player1.hittingStats?[keyPath: statType.keyPath]
            let stat2 = player2.hittingStats?[keyPath: statType.keyPath]
            
            switch statType.valueType {
            case is Int.Type:
                let value1 = (stat1 as? Int) ?? 0
                let value2 = (stat2 as? Int) ?? 0
                return value1 < value2
            case is Double.Type:
                let value1 = (stat1 as? Double) ?? 0.0
                let value2 = (stat2 as? Double) ?? 0.0
                return value1 < value2
            default:
                return false
            }
        }
    }
}
