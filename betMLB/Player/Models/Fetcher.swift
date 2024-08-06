//  Fetcher.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation
import SwiftUI

class Fetcher {
    enum FetcherError: Error {
        case invalidURL(String)
        case requestFailed(String)
        case decodingError(String)
        case missingData(String)
        case unknownError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL(let urlString):
                return "Invalid URL: \(urlString)"
            case .requestFailed(let message):
                return "Request failed: \(message)"
            case .decodingError(let message):
                return "Decoding error: \(message)"
            case .missingData(let message):
                return "Missing data: \(message)"
            case .unknownError(let message):
                return "Unknown error: \(message)"
            }
        }
        
        var localizedDescription: String {
            return errorDescription ?? "An error occurred."
        }
    }
    
    // Returns list of all players
    func fetchPlayers() async throws -> [Player] {
        let urlString = "https://statsapi.mlb.com/api/v1/sports/1/players/?season=2025"
        guard let url = URL(string: urlString) else {
            let error = FetcherError.invalidURL(urlString)
            print("Error: \(error.localizedDescription)")
            throw error
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlayerResponse.self, from: data)
            return response.people
        } catch {
            let fetcherError = FetcherError.decodingError("Failed to decode player data: \(error.localizedDescription)")
            print("Error: \(fetcherError.localizedDescription)")
            throw fetcherError
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
        let urlString = "https://www.fangraphs.com/api/leaders/major-league/data?pos=all&stats=\(statType.rawValue)&lg=all&qual=0&pageitems=9999&rost=1&season=2024"
        guard let url = URL(string: urlString) else {
            let error = FetcherError.invalidURL(urlString)
            print("Error: \(error.localizedDescription)")
            throw error
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(StatsResponse<T>.self, from: data)
            return response.data
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return []
    }
    
    func fetchHeadshotURL(for player: Player) async throws -> URL? {
        guard let id = player.headshotId else {
            let error = FetcherError.missingData("Player headshot ID is missing.")
            // print("Error: \(error.localizedDescription)")
            throw error
        }
        let playerInfoString = "https://www.fangraphs.com/api/players/stats?playerid=\(id)&position="
        guard let url = URL(string: playerInfoString) else {
            let error = FetcherError.invalidURL(playerInfoString)
            print("Error: \(error.localizedDescription)")
            throw error
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let headshotResponse = try JSONDecoder().decode(PlayerInfo.self, from: data)
            return URL(string: headshotResponse.playerInfo.urlHeadshot)
        } catch {
            let fetcherError = FetcherError.decodingError("Failed to decode headshot data: \(error.localizedDescription)")
            print("Error: \(fetcherError.localizedDescription)")
            throw fetcherError
        }
    }
}
