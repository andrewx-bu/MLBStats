//  Fetcher.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation

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
            let error = FetcherError.invalidURL
            print("Invalid players list URL: \(error.localizedDescription)")
            throw error
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlayerResponse.self, from: data)
            return response.people
        } catch {
            let error = FetcherError.decodingError
            print("Error decoding players list: \(error.localizedDescription)")
            throw error
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
        let urlString = "https://www.fangraphs.com/api/leaders/major-league/data?pos=all&stats=\(statType.rawValue)&lg=all&qual=y&pageitems=25&rost=1&season=2024"
        guard let url = URL(string: urlString) else {
            let error = FetcherError.invalidURL
            print("Error (\(statType.rawValue)): \(error.localizedDescription)")
            throw error
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(StatsResponse<T>.self, from: data)
            return response.data
        } catch {
            let error = FetcherError.decodingError
            print("Error (\(statType.rawValue)): \(error.localizedDescription)")
            throw error
        }
    }
}

