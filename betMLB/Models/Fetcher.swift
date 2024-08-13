//  Fetcher.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation
import SwiftUI

class Fetcher {
    // Returns list of all players
    func fetchPlayers() async throws -> [Player] {
        let urlString = "https://statsapi.mlb.com/api/v1/sports/1/players/?season=2025"
        guard let url = URL(string: urlString) else {
            print("fetchPlayers: Invalid URL string: \(urlString)")
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlayerResponse.self, from: data)
            return response.people
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
            print("fetchPlayers: \(error)")
            throw error
        }
        return []
    }
    
    // Returns list of all teams
    func fetchTeams() async throws -> [Team] {
        let urlString = "https://statsapi.mlb.com/api/v1/teams?sportId=1"
        guard let url = URL(string: urlString) else {
            print("fetchTeams: Invalid URL string: \(urlString)")
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TeamResponse.self, from: data)
            return response.teams
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
            print("fetchTeams: \(error)")
            throw error
        }
        return []
    }
    
    // Headshot for player
    func fetchPlayerImage(for player: Player) async -> Image? {
        guard let id = player.headshotId else {
            print("fetchPlayerImage: Player has no headshot ID")
            return nil
        }
        
        let playerInfoString = "https://www.fangraphs.com/api/players/stats?playerid=\(id)&position="
        guard let url = URL(string: playerInfoString) else {
            print("fetchPlayerImage: Invalid URL string: \(playerInfoString)")
            return nil
        }
        
        do {
            // Fetch player info to get headshot URL
            let (data, _) = try await URLSession.shared.data(from: url)
            let headshotResponse = try JSONDecoder().decode(PlayerInfo.self, from: data)
            
            guard let png = headshotResponse.playerInfo.urlHeadshot, let headshotURL = URL(string: png) else {
                print("fetchPlayerImage: Player has no headshot URL")
                return nil
            }
            
            // Fetch the headshot image
            let (imageData, _) = try await URLSession.shared.data(from: headshotURL)
            if let uiImage = UIImage(data: imageData) {
                return Image(uiImage: uiImage)
            }
        } catch {
            print("fetchPlayerImage: Error fetching player image for player \(player.id): \(error)")
        }
        
        return nil
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
            print("fetchStats (\(statType.rawValue)): Invalid URL string: \(urlString)")
            throw URLError(.badURL)
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
            print("fetchStats (\(statType.rawValue)): \(error)")
            throw error
        }
        return []
    }
    
    func fetchTeamStats<T: Decodable>(statType: StatType) async throws -> [T] {
        let urlString = "https://www.fangraphs.com/api/leaders/major-league/data?pos=all&stats=\(statType.rawValue)&lg=all&qual=y&season=2024&team=0%2Cts"
        guard let url = URL(string: urlString) else {
            print("fetchTeamStats (\(statType.rawValue)): Invalid URL string: \(urlString)")
            throw URLError(.badURL)
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
            print("fetchTeamStats (\(statType.rawValue)): \(error)")
            throw error
        }
        return []
    }
    
    // func fetchLeagueStats
}
