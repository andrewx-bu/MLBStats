//  Fetcher.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation
import SwiftUI

class Fetcher {
    enum FetcherError: LocalizedError {
        case invalidURL
        case requestFailed
        case decodingError
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .requestFailed:
                return "The request to fetch data failed."
            case .decodingError:
                return "Failed to decode the response data."
            case .unknownError:
                return "An unknown error occurred."
            }
        }
    }
    
    // Returns list of all players
    func fetchPlayers() async throws -> [Player] {
        let urlString = "https://statsapi.mlb.com/api/v1/sports/1/players/?season=2025"
        guard let url = URL(string: urlString) else {
            throw handleError(.invalidURL, context: "players list URL")
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlayerResponse.self, from: data)
            return response.people
        } catch {
            throw handleError(.decodingError, context: "players list")
        }
    }
    
    enum StatType: String {
        case hitting = "bat"
        case pitching = "pit"
        case fielding = "fld"
    }
    
    struct StatsResponse<T: Decodable>: Decodable {
        let data: [T]
    }
    
    // Returns array of specified stats
    func fetchStats<T: Decodable>(statType: StatType) async throws -> [T] {
        let urlString = "https://www.fangraphs.com/api/leaders/major-league/data?pos=all&stats=\(statType.rawValue)&lg=all&qual=0&pageitems=99&rost=1&season=2024&month=11"
        print (urlString)
        guard let url = URL(string: urlString) else {
            throw handleError(.invalidURL, context: "(\(statType.rawValue))")
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(StatsResponse<T>.self, from: data)
            return response.data
        } catch {
            throw handleError(.decodingError, context: "\(statType.rawValue)")
        }
    }
    
    func fetchHeadshotURL(for player: Player) async throws -> URL? {
        guard let id = player.headshotId else {
            throw FetcherError.requestFailed
            // throw handleError(.requestFailed, context: "(no headshot)")
        }
        let playerInfoString = "https://www.fangraphs.com/api/players/stats?playerid=\(id)&position="
        guard let url = URL(string: playerInfoString) else {
            throw handleError(.invalidURL, context: "player info URL")
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let headshotResponse = try JSONDecoder().decode(PlayerInfo.self, from: data)
            return URL(string: headshotResponse.playerInfo.urlHeadshot)
        } catch {
            throw handleError(.requestFailed, context: "fetch headshot URL")
        }
    }
}

extension Fetcher {
    private func handleError(_ error: FetcherError, context: String) -> FetcherError {
        print("Error (\(context)): \(error.localizedDescription)")
        return error
    }
}
