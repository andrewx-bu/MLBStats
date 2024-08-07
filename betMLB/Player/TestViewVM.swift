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
    
    private var loadDataTask: Task<Void, Never>?
    
    func loadData() async {
        print("Starting loadData")
        loadDataTask = Task { // Start a new task
            do {
                print("Task started")
                async let fetchedPlayers = fetcher.fetchPlayers()
                async let fetchedHittingStats: [HittingStats] = fetcher.fetchStats(statType: .hitting)
                async let fetchedPitchingStats: [PitchingStats] = fetcher.fetchStats(statType: .pitching)
                async let fetchedFieldingStats: [FieldingStats] = fetcher.fetchStats(statType: .fielding)
                
                let players = try await fetchedPlayers
                let hittingStats = try await fetchedHittingStats
                let pitchingStats = try await fetchedPitchingStats
                let fieldingStats = try await fetchedFieldingStats
                
                self.players = players
                let hittingStatsDictionary = dictionaryMaker.makeHittingDictionary(hittingStats: hittingStats)
                let pitchingStatsDictionary = dictionaryMaker.makePitchingDictionary(pitchingStats: pitchingStats)
                let fieldingStatsDictionary = dictionaryMaker.makeFieldingDictionary(fieldingStats: fieldingStats)
                
                updatePlayersWithStats(hittingStatsDictionary: hittingStatsDictionary, pitchingStatsDictionary: pitchingStatsDictionary, fieldingStatsDictionary: fieldingStatsDictionary)
                
                await fetchPlayerImages()
            } catch {
                print("loadData: Error fetching data")
            }
        }
    }
    
    func cancelLoadingTasks() {
        print("Cancelling loadData task")
        loadDataTask?.cancel()
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
        await withTaskGroup(of: (Int, Image?).self) { group in
            for player in players {
                group.addTask {
                    do {
                        if let headshotURL = try await self.fetcher.fetchHeadshotURL(for: player) {
                            let (data, _) = try await URLSession.shared.data(from: headshotURL)
                            if let uiImage = UIImage(data: data) {
                                let image = Image(uiImage: uiImage)
                                return (player.id, image)
                            }
                        }
                    } catch {
                        print("fetchPlayerImages: Error fetching headshot image for player \(player.id)")
                    }
                    return (player.id, nil)
                }
            }
            
            for await (playerId, image) in group {
                if let image = image {
                    playerImages[playerId] = image
                }
            }
        }
    }
}
