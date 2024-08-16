//  DetailGameView.swift
//  betMLB
//  Created by Andrew Xin on 8/14/24.

import SwiftUI

struct DetailGameView: View {
    @State private var game: ScheduleDate.Game
    private let fetcher = Fetcher()
    private let dictionaryMaker = DictionaryMaker()
    @State private var lineupData: LineupData? = nil
    @State private var players: [SimplePlayer] = []
    @State private var hittingStatsDictionary: HittingStatsDictionary = [:]
    @State private var pitchingStatsDictionary: PitchingStatsDictionary = [:]
    @State private var fieldingStatsDictionary: FieldingStatsDictionary = [:]
    
    init(detailGame: ScheduleDate.Game) {
        game = detailGame
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Text("Venue: \(game.venue.name)")
                Text("Status: \(game.status.detailedState)")
                Text("Game ID: \(game.gamePk)")
                if let lineupData = self.lineupData {
                    Text("Away Batters")
                        .font(.title2)
                    ForEach(lineupData.awayBatters, id: \.self) { batterID in
                        if let batter = findPlayer(by: batterID) {
                            Text("Name: \(batter.person.fullName)")
                        } else {
                            Text("Batter ID: \(batterID) (Not found)")
                        }
                    }
                    
                    Text("Away Starting Pitchers")
                        .font(.headline)
                    ForEach(lineupData.awayStartingPitchers, id: \.self) { pitcherID in
                        if let pitcher = findPlayer(by: pitcherID) {
                            Text("Name: \(pitcher.person.fullName)")
                        } else {
                            Text("Pitcher ID: \(pitcherID) (Not found)")
                        }
                    }
                    
                    Text("Away Bullpen")
                        .font(.headline)
                    ForEach(lineupData.awayBullpen, id: \.self) { bullpenID in
                        Text("Bullpen ID: \(bullpenID)")
                    }
                    
                    Text("Home Batters")
                        .font(.headline)
                    ForEach(lineupData.homeBatters, id: \.self) { batterID in
                        if let batter = findPlayer(by: batterID) {
                            Text("Name: \(batter.person.fullName)")
                        } else {
                            Text("Batter ID: \(batterID) (Not found)")
                        }
                    }
                    
                    Text("Home Starting Pitchers")
                        .font(.headline)
                    ForEach(lineupData.homeStartingPitchers, id: \.self) { pitcherID in
                        Text("Pitcher ID: \(pitcherID)")
                    }
                    
                    Text("Home Bullpen")
                        .font(.headline)
                    ForEach(lineupData.homeBullpen, id: \.self) { bullpenID in
                        Text("Bullpen ID: \(bullpenID)")
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(width: 300)
        .task {
            await loadData()
        }
    }
    
    // Fetches both teams rosters and starting lineups
    private func loadData() async {
        do {
            await loadLineups()
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
    
    private func loadLineups() async {
        do {
            self.lineupData = try await fetcher.fetchLineups(gamePk: self.game.gamePk)
        } catch {
            print("loadGames: Error fetching data")
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
