//  TestViewVM.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation
import SwiftUI

@Observable class TestViewVM {
    private let fetcher = Fetcher()
    private let dictionaryMaker = DictionaryMaker()
    
    var players: [Player] = []
    var hittingStatsDictionary: HittingStatsDictionary = [:]
    var pitchingStatsDictionary: PitchingStatsDictionary = [:]
    var fieldingStatsDictionary: FieldingStatsDictionary = [:]
    
    var playerImages: [Int: Image] = [:]
    
    func loadData() async {
        do {
            players = try await fetcher.fetchPlayers()
            
            let fetchedHittingStats: [HittingStats] = try await fetcher.fetchStats(statType: .hitting)
            let hittingStatsDictionary = dictionaryMaker.makeHittingDictionary(hittingStats: fetchedHittingStats)
            
            let fetchedPitchingStats: [PitchingStats] = try await fetcher.fetchStats(statType: .pitching)
            let pitchingStatsDictionary = dictionaryMaker.makePitchingDictionary(pitchingStats: fetchedPitchingStats)
            
            let fetchedFieldingStats: [FieldingStats] = try await fetcher.fetchStats(statType: .fielding)
            let fieldingStatsDictionary = dictionaryMaker.makeFieldingDictionary(fieldingStats: fetchedFieldingStats)
            
            updatePlayersWithStats(hittingStatsDictionary: hittingStatsDictionary, pitchingStatsDictionary: pitchingStatsDictionary, fieldingStatsDictionary: fieldingStatsDictionary)
            
            await fetchPlayerImages()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    // Populate player's hitting/pitching/fieldingStats
    private func updatePlayersWithStats(hittingStatsDictionary: HittingStatsDictionary, pitchingStatsDictionary: PitchingStatsDictionary, fieldingStatsDictionary: FieldingStatsDictionary
    ) {
        players = players.map { player in
            var updatedPlayer = player
            
            // Match player with his stats
            if let hitting = hittingStatsDictionary[player.id] {
                updatedPlayer.hittingStats = hitting
                // Extract fangraphs id for getting headshot later
                updatedPlayer.headshotId = hitting.playerid
            }
            
            if let pitching = pitchingStatsDictionary[player.id] {
                updatedPlayer.pitchingStats = pitching
                updatedPlayer.headshotId = pitching.playerid
            }
            
            if let fielding = fieldingStatsDictionary[player.id] {
                updatedPlayer.fieldingStats = fielding
                updatedPlayer.headshotId = fielding.playerid
            }
            
            return updatedPlayer
        }
    }
    
    // Fetch All Player Images
    private func fetchPlayerImages() async {
        for player in players {
            do {
                if let headshotURL = try await fetcher.fetchHeadshotURL(for: player) {
                    let (data, _) = try await URLSession.shared.data(from: headshotURL)
                    if let uiImage = UIImage(data: data) {
                        let image = Image(uiImage: uiImage)
                        playerImages[player.id] = image
                    }
                }
            } catch {
                // print("Error fetching headshot image for player \(player.id): \(error.localizedDescription)")
            }
        }
    }
}
