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
        } catch {
            print("fetchPlayers: Decoding error")
            throw error
        }
    }
    
    func fetchHeadshotURL(for player: Player) async throws -> URL? {
        guard let id = player.headshotId else {
            print("fetchHeadshotURL: Player has no headshot ID")
            return nil
        }
        let playerInfoString = "https://www.fangraphs.com/api/players/stats?playerid=\(id)&position="
        guard let url = URL(string: playerInfoString) else {
            print("fetchHeadshotURL: Invalid URL string: \(playerInfoString)")
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let headshotResponse = try JSONDecoder().decode(PlayerInfo.self, from: data)
            guard let png = headshotResponse.playerInfo.urlHeadshot else {
                // print("fetchHeadshotURL: Player has no headshot URL")
                return nil
            }
            return URL(string: png)
        } catch {
            // print("fetchHeadshotURL: Decoding Error")
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
        let urlString = "https://www.fangraphs.com/api/leaders/major-league/data?pos=all&stats=\(statType.rawValue)&lg=all&qual=0&pageitems=9999&rost=1&season=2024"
        guard let url = URL(string: urlString) else {
            print("fetchStats (\(statType.rawValue)): Invalid URL string: \(urlString)")
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(StatsResponse<T>.self, from: data)
            return response.data
        } catch {
            print("fetchStats (\(statType.rawValue)): Decoding Error")
            throw error
        }
        /*
         catch DecodingError.dataCorrupted(let context) {
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
         */
    }
}
