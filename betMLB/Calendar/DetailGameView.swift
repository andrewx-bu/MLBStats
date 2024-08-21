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
    @State private var playerImages: [Int: Image] = [:]
    @State private var morePitcherStatsExpanded = false
    @State var teams: [Team] = []
    @State private var teamHittingStatsDictionary: HittingStatsDictionary = [:]
    @State private var teamPitchingStatsDictionary: PitchingStatsDictionary = [:]
    @State private var teamFieldingStatsDictionary: FieldingStatsDictionary = [:]
    @State private var inningCount: Int = 9
    let columns = [
        GridItem(.flexible(minimum: 240)),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let lineScoreColumns = [
        GridItem(.fixed(35)), // Empty cell or team name
        GridItem(.fixed(15)), // 1
        GridItem(.fixed(15)), // 2
        GridItem(.fixed(15)), // 3
        GridItem(.fixed(15)), // 4
        GridItem(.fixed(15)), // 5
        GridItem(.fixed(15)), // 6
        GridItem(.fixed(15)), // 7
        GridItem(.fixed(15)), // 8
        GridItem(.fixed(15)), // 9
        GridItem(.fixed(15)), // R
        GridItem(.fixed(15)), // H
        GridItem(.fixed(15)), // E
    ]
    @State private var awayRuns: Int = 0
    @State private var awayHits: Int = 0
    @State private var awayErrors: Int = 0
    @State private var homeRuns: Int = 0
    @State private var homeHits: Int = 0
    @State private var homeErrors: Int = 0
    
    init(detailGame: ScheduleDate.Game) {
        game = detailGame
    }
    
    var body: some View {
        ScrollView {
            // Summary Box
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
            // Line Score
            VStack(alignment: .leading) {
                Text("Linescore")
                    .font(.headline)
                Divider()
                    .frame(width: 175, height: 3)
                    .background(.indigo)
                if let lineScore = self.lineScore, let inningState = lineScore.inningState, let inningOrdinal = lineScore.currentInningOrdinal {
                    Text("\(inningState) \(inningOrdinal)")
                        .font(.footnote)
                }
                ScrollView(.horizontal) {
                    LazyVGrid(columns: lineScoreColumns) {
                        Text("")
                        ForEach(1...9, id: \.self) { inning in
                            Text("\(inning)")
                        }
                        Text("R")
                        Text("H")
                        Text("E")
                        
                        Text(mapTeamIdToAbbreviation(fromId: game.teams.away.team.id))
                        if let lineScore = self.lineScore {
                            ForEach(lineScore.innings, id: \.num) { inning in
                                if let runs = inning.away.runs {
                                    Text("\(runs)")
                                } else {
                                    Circle()
                                        .fill(game.status.detailedState == "In Progress" ? Color.red : Color.indigo)
                                        .frame(width: 7.5, height: 7.5)
                                }
                            }
                        } else {
                            ForEach(100...108, id: \.self) { _ in
                                Circle()
                                    .fill(game.status.detailedState == "In Progress" ? Color.red : Color.indigo)
                                    .frame(width: 7.5, height: 7.5)
                            }
                        }
                        Text("\(awayRuns)")
                        Text("\(awayHits)")
                        Text("\(awayErrors)")
                        
                        Text(mapTeamIdToAbbreviation(fromId: game.teams.home.team.id))
                        if let lineScore = self.lineScore {
                            ForEach(lineScore.innings, id: \.num) { inning in
                                if let runs = inning.home.runs {
                                    Text("\(runs)")
                                } else {
                                    Circle()
                                        .fill(game.status.detailedState == "In Progress" ? Color.red : Color.indigo)
                                        .frame(width: 7.5, height: 7.5)
                                }
                            }
                        } else {
                            ForEach(200...208, id: \.self) { _ in
                                Circle()
                                    .fill(game.status.detailedState == "In Progress" ? Color.red : Color.indigo)
                                    .frame(width: 7.5, height: 7.5)
                            }
                        }
                        Text("\(homeRuns)")
                        Text("\(homeHits)")
                        Text("\(homeErrors)")
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemGray6))
            )
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                            } else {
                                Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                                    } else {
                                        Text("N/A")
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
                Text("Team Stats")
                    .font(.headline)
                Divider()
                    .frame(width: 175, height: 3)
                    .background(.indigo)
                HStack(spacing: 25) {
                    Spacer()
                    Image.teamLogoImage(for: game.teams.away.team.id)
                        .frame(width: 20, height: 20)
                    Image.teamLogoImage(for: game.teams.home.team.id)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 25)
                .frame(maxWidth: .infinity)
                Divider()
                if let awayTeam = findTeam(by: game.teams.away.team.id), let homeTeam = findTeam(by: game.teams.home.team.id) {
                    if let awayHittingStats = awayTeam.hittingStats, let awayPitchingStats = awayTeam.pitchingStats, let homeHittingStats = homeTeam.hittingStats, let homePitchingStats = homeTeam.pitchingStats {
                        LazyVGrid(columns: columns) {
                            Group {
                                Text("Batting Average")
                                let awayAVG = String(format: "%.3f", awayHittingStats.AVG)
                                    .split(separator: ".")
                                    .last ?? ""
                                let homeAVG = String(format: "%.3f", homeHittingStats.AVG)
                                    .split(separator: ".")
                                    .last ?? ""
                                Text(".\(awayAVG)")
                                Text(".\(homeAVG)")
                                
                                Text("Runs")
                                Text("\(awayHittingStats.R)")
                                Text("\(homeHittingStats.R)")
                                
                                Text("Hits")
                                Text("\(awayHittingStats.H)")
                                Text("\(homeHittingStats.H)")
                                
                                Text("Home Runs")
                                Text("\(awayHittingStats.HR)")
                                Text("\(homeHittingStats.HR)")
                                
                                Text("On Base Percentage")
                                let awayOBP = String(format: "%.3f", awayHittingStats.OBP)
                                    .split(separator: ".")
                                    .last ?? ""
                                let homeOBP = String(format: "%.3f", homeHittingStats.OBP)
                                    .split(separator: ".")
                                    .last ?? ""
                                Text(".\(awayOBP)")
                                Text(".\(homeOBP)")
                                
                                Text("Slugging Percentage")
                                Text(String(format: "%.3f", awayHittingStats.SLG))
                                Text(String(format: "%.3f", homeHittingStats.SLG))
                                
                                Text("Earned Run AVG")
                                Text(String(format: "%.2f", awayPitchingStats.ERA))
                                Text(String(format: "%.2f", homePitchingStats.ERA))
                                
                                Text("Walks Plus Hits per IP")
                                Text(String(format: "%.2f", awayPitchingStats.WHIP))
                                Text(String(format: "%.2f", homePitchingStats.WHIP))
                                
                                Text("Walks")
                                Text("\(awayPitchingStats.BB)")
                                Text("\(homePitchingStats.BB)")
                                
                                Text("Strikeouts")
                                Text("\(awayPitchingStats.strikes)")
                                Text("\(homePitchingStats.strikes)")
                                
                                Text("Opponent Batting Average")
                                let awayOppAVG = String(format: "%.3f", awayPitchingStats.AVG)
                                    .split(separator: ".")
                                    .last ?? ""
                                let homeOppAVG = String(format: "%.3f", homePitchingStats.AVG)
                                    .split(separator: ".")
                                    .last ?? ""
                                Text(".\(awayOppAVG)")
                                Text(".\(homeOppAVG)")
                            }
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Text("Not Found")
                    }
                } else {
                    Text("Not Found")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemGray6))
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
        }
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
            
            async let fetchedTeams = fetcher.fetchTeams()
            async let fetchedTeamHittingStats: [HittingStats] = fetcher.fetchTeamStats(statType: .hitting)
            async let fetchedTeamPitchingStats: [PitchingStats] = fetcher.fetchTeamStats(statType: .pitching)
            async let fetchedTeamFieldingStats: [FieldingStats] = fetcher.fetchTeamStats(statType: .fielding)
            
            let allPlayers = try await fetchedAwayPlayers + fetchedHomePlayers
            let hittingStats = try await fetchedHittingStats
            let pitchingStats = try await fetchedPitchingStats
            let fieldingStats = try await fetchedFieldingStats
            
            let teams = try await fetchedTeams
            let teamHittingStats = try await fetchedTeamHittingStats
            let teamPitchingStats = try await fetchedTeamPitchingStats
            let teamFieldingStats = try await fetchedTeamFieldingStats
            
            self.players = allPlayers
            let hittingStatsDictionary = dictionaryMaker.makePlayerHittingDictionary(hittingStats: hittingStats)
            let pitchingStatsDictionary = dictionaryMaker.makePlayerPitchingDictionary(pitchingStats: pitchingStats)
            let fieldingStatsDictionary = dictionaryMaker.makePlayerFieldingDictionary(fieldingStats: fieldingStats)
            
            self.teams = teams
            let teamHittingStatsDictionary = dictionaryMaker.makeTeamHittingDictionary(hittingStats: teamHittingStats)
            let teamPitchingStatsDictionary = dictionaryMaker.makeTeamPitchingDictionary(pitchingStats: teamPitchingStats)
            let teamFieldingStatsDictionary = dictionaryMaker.makeTeamFieldingDictionary(fieldingStats: teamFieldingStats)
            
            updatePlayersWithStats(hittingStatsDictionary: hittingStatsDictionary, pitchingStatsDictionary: pitchingStatsDictionary, fieldingStatsDictionary: fieldingStatsDictionary)
            
            updateTeamsWithStats(hittingStatsDictionary: teamHittingStatsDictionary, pitchingStatsDictionary: teamPitchingStatsDictionary, fieldingStatsDictionary: teamFieldingStatsDictionary)
            
            if let lineScore = self.lineScore {
                inningCount = lineScore.innings.count
                for inning in lineScore.innings {
                    if let runs = inning.away.runs {
                        awayRuns += runs
                    }
                    awayHits += inning.away.hits
                    awayErrors += inning.away.errors
                    if let runs = inning.home.runs {
                        homeRuns += runs
                    }
                    homeHits += inning.home.hits
                    homeErrors += inning.home.errors
                }
            }
            
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
    
    private func updateTeamsWithStats(hittingStatsDictionary: HittingStatsDictionary, pitchingStatsDictionary: PitchingStatsDictionary, fieldingStatsDictionary: FieldingStatsDictionary
    ) {
        teams = teams.map { team in
            var updatedTeam = team
            
            // Match team with its stats
            if let hitting = hittingStatsDictionary[mapTeamId(fromStatsAPI: team.id) ?? 1] {
                updatedTeam.hittingStats = hitting
            }
            
            if let pitching = pitchingStatsDictionary[mapTeamId(fromStatsAPI: team.id) ?? 1] {
                updatedTeam.pitchingStats = pitching
            }
            
            if let fielding = fieldingStatsDictionary[mapTeamId(fromStatsAPI: team.id) ?? 1] {
                updatedTeam.fieldingStats = fielding
            }
            
            return updatedTeam
        }
    }
    
    private func findPlayer(by id: Int) -> SimplePlayer? {
        return players.first { $0.person.id == id }
    }
    
    private func findTeam(by id: Int) -> Team? {
        return teams.first { $0.id == id }
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
