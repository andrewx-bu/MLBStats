//  DictionaryMaker.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

typealias HittingStatsDictionary = [Int: HittingStats]
typealias PitchingStatsDictionary = [Int: PitchingStats]
typealias FieldingStatsDictionary = [Int: FieldingStats]

class DictionaryMaker {
    func makeHittingDictionary(hittingStats: [HittingStats]) -> HittingStatsDictionary {
        var dictionary = HittingStatsDictionary()
        for stats in hittingStats {
            dictionary[stats.xMLBAMID] = stats
        }
        return dictionary
    }
    
    func makePitchingDictionary(pitchingStats: [PitchingStats]) -> PitchingStatsDictionary {
        var dictionary = PitchingStatsDictionary()
        for stats in pitchingStats {
            dictionary[stats.xMLBAMID] = stats
        }
        return dictionary
    }
    
    func makeFieldingDictionary(fieldingStats: [FieldingStats]) -> FieldingStatsDictionary {
        var dictionary = FieldingStatsDictionary()
        for stats in fieldingStats {
            dictionary[stats.xMLBAMID] = stats
        }
        return dictionary
    }
}

class Fetcher {
    // Returns list of all players
    func fetchPlayers() async throws -> [Player] {
        let urlString = "https://statsapi.mlb.com/api/v1/sports/1/players/?season=2025"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 1, userInfo: nil)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(PlayerResponse.self, from: data)
        return response.people
    }
    
    enum StatType: String {
        case hitting = "bat"
        case pitching = "pit"
        case fielding = "fld"
    }
    
    struct StatsResponse<T: Decodable>: Decodable {
        let data: [T]
    }

    // Returns Array of Specified Stats
    func fetchStats<T: Decodable>(statType: StatType) async throws -> [T] {
        let urlString = "https://www.fangraphs.com/api/leaders/major-league/data?pos=all&stats=\(statType.rawValue)&lg=all&qual=y&pageitems=25&rost=1&season=2024"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 1, userInfo: nil)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(StatsResponse<T>.self, from: data)
        return response.data
    }
}
