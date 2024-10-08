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
    @State private var TBF: Int = 20
    @State private var multiples: [Int] = []
    @State private var awayWRC5: Double = 0.0
    @State private var homeWRC5: Double = 0.0
    @State private var awayRAper5: Double = 0.0
    @State private var homeRAper5: Double = 0.0
    let columns = [
        GridItem(.flexible(minimum: 240)),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @State private var lineScoreColumns = [
        GridItem(.fixed(35)), // Empty cell or team name
        GridItem(.fixed(15)), // R
        GridItem(.fixed(15)), // H
        GridItem(.fixed(15)), // E
    ]
    let predictionColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @State private var awayRuns: Int = 0
    @State private var awayHits: Int = 0
    @State private var awayErrors: Int = 0
    @State private var homeRuns: Int = 0
    @State private var homeHits: Int = 0
    @State private var homeErrors: Int = 0
    @State private var stepperValues: [Int] = []
    
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
                    HStack {
                        Text("\(inningState) \(inningOrdinal)")
                            .font(.footnote)
                        if game.status.detailedState == "In Progress" {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 7.5, height: 7.5)
                        }
                    }
                }
                ScrollView(.horizontal) {
                    LazyVGrid(columns: lineScoreColumns) {
                        Text("")
                        ForEach(1...inningCount, id: \.self) { inning in
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
                            ForEach(101...inningCount + 100, id: \.self) { _ in
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
                            ForEach(201...inningCount + 200, id: \.self) { _ in
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
            VStack(alignment: .leading) {
                Text("Prediction")
                    .font(.headline)
                Divider()
                    .frame(width: 175, height: 3)
                    .background(.indigo)
                
                /*
                if let awayTeam = findTeam(by: game.teams.away.team.id), let homeTeam = findTeam(by: game.teams.home.team.id) {
                    if let awayHittingStats = awayTeam.hittingStats, let awayPitchingStats = awayTeam.pitchingStats, let homeHittingStats = homeTeam.hittingStats, let homePitchingStats = homeTeam.pitchingStats {
                        LazyVGrid(columns: predictionColumns) {
                            Text("")
                            Text("\(awayTeam.name)")
                            Text("\(homeTeam.name)")
                            
                            Text("RS/G")
                            if let ATG = awayHittingStats.TG, let HTG = homeHittingStats.TG {
                                let awayRSG = Double(awayHittingStats.R) / Double(ATG)
                                let homeRSG = Double(homeHittingStats.R) / Double(HTG)
                                Text(String(format: "%.4f", awayRSG))
                                Text(String(format: "%.4f", homeRSG))
                            }
                            
                            Text("BB% Allowed")
                            Text(String(format: "%.4f", awayPitchingStats.bbPCT))
                            Text(String(format: "%.4f", homePitchingStats.bbPCT))
                            
                            Text("SO% Allowed")
                            Text(String(format: "%.4f", awayPitchingStats.kPCT))
                            Text(String(format: "%.4f", homePitchingStats.kPCT))
                            
                            Text("HR% Allowed")
                            let awayHR = Double(awayHittingStats.HR) / Double(awayHittingStats.PA)
                            let homeHR = Double(homeHittingStats.HR) / Double(homeHittingStats.PA)
                            Text(String(format: "%.4f", awayHR))
                            Text(String(format: "%.4f", homeHR))
                            
                            Text("FIP")
                            Text(String(format: "%.4f", awayPitchingStats.FIP))
                            Text(String(format: "%.4f", homePitchingStats.FIP))
                            
                            Text("DEF")
                            if let awayFieldingStats = awayTeam.fieldingStats, let homeFieldingStats = homeTeam.fieldingStats {
                                if let awayDef = awayFieldingStats.DEF, let homeDef = homeFieldingStats.DEF {
                                    Text(String(format: "%.4f", awayDef))
                                    Text(String(format: "%.4f", homeDef))
                                }
                                Text("UZR")
                                if let awayUZR = awayFieldingStats.UZR, let homeUZR = homeFieldingStats.UZR {
                                    Text(String(format: "%.4f", awayUZR))
                                    Text(String(format: "%.4f", homeUZR))
                                }
                            }
                            
                            Text("BABIP")
                            Text(String(format: "%.4f", awayPitchingStats.BABIP))
                            Text(String(format: "%.4f", homePitchingStats.BABIP))
                            
                            Text("BB% Factor")
                            if let awayBB = awayHittingStats.bbPCTplus, let homeBB = homeHittingStats.bbPCTplus {
                                let awayBBFactor = awayBB / 100
                                let homeBBFactor = homeBB / 100
                                Text(String(format: "%.4f", awayBBFactor))
                                Text(String(format: "%.4f", homeBBFactor))
                            }
                            
                            Text("SO% Factor")
                            if let awayK = awayHittingStats.kPCTplus, let homeK = homeHittingStats.kPCTplus {
                                let awayKFactor = awayK / 100
                                let homeKFactor = homeK / 100
                                Text(String(format: "%.4f", awayKFactor))
                                Text(String(format: "%.4f", homeKFactor))
                            }
                            
                            Text("wRC+")
                            if let awaywRC = awayHittingStats.wRCplus, let homewRC = homeHittingStats.wRCplus {
                                Text(String(format: "%.4f", awaywRC))
                                Text(String(format: "%.4f", homewRC))
                            }
                            
                        }
                        .font(.footnote)
                    }
                 }
                 */
                
                // Away Team
                VStack(alignment: .leading) {
                    Text("Away Team")
                    if let lineupData = self.lineupData {
                        ForEach(lineupData.awayBatters.indices, id: \.self) { index in
                            let batterID = lineupData.awayBatters[index]
                            if let batter = findPlayer(by: batterID) {
                                HStack(spacing: 15) {
                                    Text("\(batter.person.fullName)")
                                    if let wRCplus = batter.hittingStats?.wRCplus {
                                        let wRC = (wRCplus / 100) - 1
                                        Text("wRC+: \(String(format: "%.4f", wRC))")
                                        if let firstPitcherID = lineupData.awayStartingPitchers.first,
                                           let pitcher = findPlayer(by: firstPitcherID), let pitchingStats = pitcher.pitchingStats {
                                            let TBFper5 = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5.0
                                            let multiples = distributeAtBats(totalAtBats: Int(TBFper5.rounded()))
                                            let wRC5 = wRC * Double(multiples[index])
                                            Text("wRC/5: \(String(format: "%.4f", wRC5))")
                                                .onAppear {
                                                    awayWRC5 += wRC5
                                                }
                                        }
                                    } else if let awayTeam = findTeam(by: game.teams.away.team.id), let awayHittingStats = awayTeam.hittingStats {
                                        if let awaywRC = awayHittingStats.wRCplus {
                                            let away = (awaywRC / 100) - 1
                                            Text("wRC+: \(String(format: "%.4f", away)) (TV)")
                                            if let firstPitcherID = lineupData.awayStartingPitchers.first,  let pitcher = findPlayer(by: firstPitcherID), let pitchingStats = pitcher.pitchingStats {
                                                let TBFper5 = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5.0
                                                let multiples = distributeAtBats(totalAtBats: Int(TBFper5.rounded()))
                                                let wRC5 = away * Double(multiples[index])
                                                Text("wRC/5: \(String(format: "%.4f", wRC5))")
                                                    .onAppear {
                                                        awayWRC5 += wRC5
                                                    }
                                            }
                                        }
                                    } else {
                                        Text("N/A")
                                    }
                                }
                                Spacer()
                            }
                        }
                        Text("Expected Runs: \(String(format: "%.4f", awayWRC5))")
                        Text("Pitcher")
                            .font(.headline)
                        if let firstPitcherID = lineupData.awayStartingPitchers.first, let pitcher = findPlayer(by: firstPitcherID) {
                            Text("\(pitcher.person.fullName)")
                            if let pitchingStats = pitcher.pitchingStats {
                                let battersFacedPer5Innings = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5
                                Text("Total PA: " + String(format: "%.2f", battersFacedPer5Innings))
                                if let FIPminus = pitchingStats.FIPminus {
                                    Text("FIP-: \(String(format: "%.4f", FIPminus / 100))")
                                    Text("")
                                }
                                let RAperIP = pitchingStats.FIP/9
                                Text("RA/IP: \(String(format: "%.4f", RAperIP))")
                                Text("RA/5: \(String(format: "%.4f", (RAperIP * homeWRC5).rounded()))")
                            } else {
                                Text("Total PA: 20 (Default)")
                                if let awayTeam = findTeam(by: game.teams.away.team.id) {
                                    if let pitchingStats = awayTeam.pitchingStats {
                                        let battersFacedPer5Innings = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5
                                        Text("Total PA: " + String(format: "%.2f", battersFacedPer5Innings))
                                        if let FIPminus = pitchingStats.FIPminus {
                                            Text("FIP-: \(String(format: "%.4f", FIPminus / 100))")
                                        }
                                        let RAperIP = pitchingStats.FIP/9
                                        Text("RA/IP: \(String(format: "%.4f", RAperIP))")
                                        Text("RA/5: \(String(format: "%.4f", (RAperIP * awayWRC5).rounded()))")
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .font(.footnote)
                
                Divider()
                
                // Home Team
                VStack(alignment: .leading) {
                    Text("Home Team")
                    if let lineupData = self.lineupData {
                        ForEach(lineupData.homeBatters.indices, id: \.self) { index in
                            let batterID = lineupData.homeBatters[index]
                            if let batter = findPlayer(by: batterID) {
                                HStack(spacing: 15) {
                                    Text("\(batter.person.fullName)")
                                    if let wRCplus = batter.hittingStats?.wRCplus {
                                        let wRC = (wRCplus / 100) - 1
                                        Text("wRC+: \(String(format: "%.4f", wRC))")
                                        if let firstPitcherID = lineupData.homeStartingPitchers.first,
                                           let pitcher = findPlayer(by: firstPitcherID), let pitchingStats = pitcher.pitchingStats {
                                            let TBFper5 = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5.0
                                            let multiples = distributeAtBats(totalAtBats: Int(TBFper5.rounded()))
                                            let wRC5 = wRC * Double(multiples[index])
                                            Text("wRC/5: \(String(format: "%.4f", wRC5))")
                                                .onAppear {
                                                    homeWRC5 += wRC5
                                                }
                                        }
                                    } else if let homeTeam = findTeam(by: game.teams.home.team.id), let homeHittingStats = homeTeam.hittingStats {
                                        if let homewRC = homeHittingStats.wRCplus {
                                            let home = (homewRC / 100) - 1
                                            Text(String(format: "%.4f", home) + "(TV)")
                                            if let firstPitcherID = lineupData.homeStartingPitchers.first,  let pitcher = findPlayer(by: firstPitcherID), let pitchingStats = pitcher.pitchingStats {
                                                let TBFper5 = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5.0
                                                let multiples = distributeAtBats(totalAtBats: Int(TBFper5.rounded()))
                                                let wRC5 = home * Double(multiples[index])
                                                Text("wRC/5: \(String(format: "%.4f", wRC5))")
                                                    .onAppear {
                                                        homeWRC5 += wRC5
                                                    }
                                            }
                                        }
                                    } else {
                                        Text("N/A")
                                    }
                                }
                                Spacer()
                            }
                        }
                        Text("Expected Runs: \(String(format: "%.4f", homeWRC5))")
                        Text("Pitcher")
                            .font(.headline)
                        if let firstPitcherID = lineupData.homeStartingPitchers.first, let pitcher = findPlayer(by: firstPitcherID) {
                            Text("\(pitcher.person.fullName)")
                            if let pitchingStats = pitcher.pitchingStats {
                                let battersFacedPer5Innings = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5
                                Text("Total PA: " + String(format: "%.2f", battersFacedPer5Innings))
                                if let FIPminus = pitchingStats.FIPminus {
                                    Text("FIP-: \(String(format: "%.4f", FIPminus / 100))")
                                }
                                let RAperIP = pitchingStats.FIP/9
                                Text("RA/IP: \(String(format: "%.4f", RAperIP))")
                                Text("RA/5: \(String(format: "%.4f", (RAperIP * awayWRC5).rounded()))")
                            } else {
                                Text("Total PA: 20 (Default)")
                                if let homeTeam = findTeam(by: game.teams.home.team.id) {
                                    if let pitchingStats = homeTeam.pitchingStats {
                                        let battersFacedPer5Innings = (Double(pitchingStats.TBF) / pitchingStats.IP) * 5
                                        Text("Total PA: " + String(format: "%.2f", battersFacedPer5Innings))
                                        if let FIPminus = pitchingStats.FIPminus {
                                            Text("FIP-: \(String(format: "%.4f", FIPminus / 100))")
                                        }
                                        let RAperIP = pitchingStats.FIP/9
                                        Text("RA/IP: \(String(format: "%.4f", RAperIP))")
                                        Text("RA/5: \(String(format: "%.4f", (RAperIP * awayWRC5).rounded()))")
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .font(.footnote)
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
            
            async let fetchedHittingStats: [HittingStats] = fetcher.fetchPredictionStats(statType: .hitting)
            async let fetchedPitchingStats: [PitchingStats] = fetcher.fetchPredictionStats(statType: .pitching)
            async let fetchedFieldingStats: [FieldingStats] = fetcher.fetchPredictionStats(statType: .fielding)
            
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
                if inningCount == 0 {
                    for _ in 1...9 {
                        lineScoreColumns.append(GridItem(.fixed(15)))
                    }
                }
                for inning in lineScore.innings {
                    lineScoreColumns.append(GridItem(.fixed(15)))
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
            } else {
                for _ in 1...9 {
                    lineScoreColumns.append(GridItem(.fixed(15)))
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
    
    func distributeAtBats(totalAtBats: Int) -> [Int] {
        var atBats = Array(repeating: totalAtBats / 9, count: 9)
        let remainder = totalAtBats % 9
        
        for i in 0..<remainder {
            atBats[i] += 1
        }
        
        return atBats
    }
}
