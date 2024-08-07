//  TeamListViewVM.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import Foundation
import SwiftUI

@Observable class TeamListViewVM {
    private let fetcher = Fetcher()
    private let dictionaryMaker = DictionaryMaker()
    
    var teams: [Team] = []
    var hittingStatsDictionary: HittingStatsDictionary = [:]
    var pitchingStatsDictionary: PitchingStatsDictionary = [:]
    var fieldingStatsDictionary: FieldingStatsDictionary = [:]
    
    private var loadDataTask: Task<Void, Never>?
    
    func loadData() async {
        loadDataTask = Task {
            do {
                async let fetchedTeams = fetcher.fetchTeams()
                async let fetchedHittingStats: [HittingStats] = fetcher.fetchTeamStats(statType: .hitting)
                async let fetchedPitchingStats: [PitchingStats] = fetcher.fetchTeamStats(statType: .pitching)
                async let fetchedFieldingStats: [FieldingStats] = fetcher.fetchTeamStats(statType: .fielding)
                
                let teams = try await fetchedTeams
                let hittingStats = try await fetchedHittingStats
                let pitchingStats = try await fetchedPitchingStats
                let fieldingStats = try await fetchedFieldingStats
                
                self.teams = teams
                let hittingStatsDictionary = dictionaryMaker.makeTeamHittingDictionary(hittingStats: hittingStats)
                let pitchingStatsDictionary = dictionaryMaker.makeTeamPitchingDictionary(pitchingStats: pitchingStats)
                let fieldingStatsDictionary = dictionaryMaker.makeTeamFieldingDictionary(fieldingStats: fieldingStats)
                
                updateTeamsWithStats(hittingStatsDictionary: hittingStatsDictionary, pitchingStatsDictionary: pitchingStatsDictionary, fieldingStatsDictionary: fieldingStatsDictionary)
            } catch {
                print("loadData: Error fetching data")
            }
        }
    }
    
    func cancelLoadingTasks() {
        print("Cancelling loadData task")
        loadDataTask?.cancel()
    }
    
    // Populate team's hitting/pitching/fieldingStats. Since the ids from teams list from statsAPI we first map to fangraphs ID
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
}
