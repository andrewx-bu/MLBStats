//  TestViewVM.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation
import SwiftUI

@Observable class TestViewVM {
    var players: [Player] = []
    var hittingStats: HittingStatsDictionary = [:]
    var pitchingStats: PitchingStatsDictionary = [:]
    var fieldingStats: FieldingStatsDictionary = [:]
    
    private let fetcher = Fetcher()
    private let dictionaryMaker = DictionaryMaker()
    
    func loadData() async {
        do {
            players = try await fetcher.fetchPlayers()
            
            let fetchedHittingStats: [HittingStats] = try await fetcher.fetchStats(statType: .hitting)
            hittingStats = dictionaryMaker.makeHittingDictionary(hittingStats: fetchedHittingStats)
            
            let fetchedPitchingStats: [PitchingStats] = try await fetcher.fetchStats(statType: .pitching)
            pitchingStats = dictionaryMaker.makePitchingDictionary(pitchingStats: fetchedPitchingStats)
            
            let fetchedFieldingStats: [FieldingStats] = try await fetcher.fetchStats(statType: .fielding)
            fieldingStats = dictionaryMaker.makeFieldingDictionary(fieldingStats: fetchedFieldingStats)
            
            updatePlayersWithStats()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    // Populate player's hitting/pitching/fieldingStats
    private func updatePlayersWithStats() {
        players = players.map { player in
            var updatedPlayer = player
            
            if let hitting = hittingStats[player.id] {
                updatedPlayer.hittingStats = hitting
            }
            
            if let pitching = pitchingStats[player.id] {
                updatedPlayer.pitchingStats = pitching
            }
            
            if let fielding = fieldingStats[player.id] {
                updatedPlayer.fieldingStats = fielding
            }
            
            return updatedPlayer
        }
    }
}
