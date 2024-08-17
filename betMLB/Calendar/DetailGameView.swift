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
    
    init(detailGame: ScheduleDate.Game) {
        game = detailGame
        if game.status.detailedState == "In Progress" {
            inProgress = true
        }
    }
    
    var body: some View {
        VStack() {
            Text("\(game.teams.away.team.name) @ \(game.teams.home.team.name)")
            Text("Venue: \(game.venue.name)")
            Text("Status: \(game.status.detailedState)")
            Text("Game ID: \(game.gamePk)")
            if let lineScore = self.lineScore {
                if let balls = lineScore.balls {
                    Text("\(balls)")
                }
            }
            HStack {
                Spacer()
                Image.teamLogoImage(for: game.teams.away.team.id)
                    .frame(width: 40, height: 40)
                VStack {
                    Text("\(mapTeamIdToAbbreviation(fromId: game.teams.away.team.id))")
                        .font(.callout)
                    Text("\(game.teams.away.leagueRecord.wins)-\(game.teams.away.leagueRecord.losses)")
                }
                .font(.caption2)
                Spacer()
                Text("\(game.gameDate.formattedGameTime())")
                Spacer()
                VStack {
                    Text("\(mapTeamIdToAbbreviation(fromId: game.teams.home.team.id))")
                        .font(.callout)
                    Text("\(game.teams.home.leagueRecord.wins)-\(game.teams.home.leagueRecord.losses)")
                }
                .font(.caption2)
                Image.teamLogoImage(for: game.teams.home.team.id)
                    .frame(width: 40, height: 40)
                Spacer()
            }
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
        }
        .font(.footnote)
        HStack {
            if let lineupData = self.lineupData {
                VStack {
                    ScrollView {
                        Text("Away Pitchers")
                            .font(.headline)
                        ForEach(lineupData.awayStartingPitchers, id: \.self) { pitcherID in
                            if let pitcher = findPlayer(by: pitcherID) {
                                Text("\(pitcher.person.fullName)")
                            } else {
                                Text("Pitcher ID: \(pitcherID) (Not found)")
                            }
                        }
                        
                        Text("Away Batters")
                            .font(.headline)
                        ForEach(lineupData.awayBatters, id: \.self) { batterID in
                            if let batter = findPlayer(by: batterID) {
                                Text("\(batter.person.fullName)")
                            } else {
                                Text("Batter ID: \(batterID) (Not found)")
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                Divider()
                    .frame(width: 10)
                    .foregroundStyle(.indigo)
                VStack {
                    ScrollView {
                        Text("Home Pitchers")
                            .font(.headline)
                        ForEach(lineupData.homeStartingPitchers, id: \.self) { pitcherID in
                            if let pitcher = findPlayer(by: pitcherID) {
                                Text("\(pitcher.person.fullName)")
                            } else {
                                Text("Pitcher ID: \(pitcherID) (Not found)")
                            }
                        }
                        
                        Text("Home Batters")
                            .font(.headline)
                        ForEach(lineupData.homeBatters, id: \.self) { batterID in
                            if let batter = findPlayer(by: batterID) {
                                Text("\(batter.person.fullName)")
                            } else {
                                Text("Batter ID: \(batterID) (Not found)")
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .frame(maxWidth: .infinity)
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
}
