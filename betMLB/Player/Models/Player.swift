//  Player.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

struct Player: Identifiable, Decodable {
    let id: Int
    let fullName: String
    
    var hittingStats: HittingStats?
    var pitchingStats: PitchingStats?
    var fieldingStats: FieldingStats?
}

struct PlayerResponse: Decodable {
    let people: [Player]
}

// Stats
struct HittingStats: Decodable {
    let xMLBAMID: Int
    let Bats: String
    let AVG: Double
}

struct HittingRespone: Decodable {
    let data: [HittingStats]
}

struct PitchingStats: Decodable {
    let xMLBAMID: Int
    let Throws: String
    let ERA: Double
}

struct PitchingResponse: Decodable {
    let data: [PitchingStats]
}

struct FieldingStats: Decodable {
    let xMLBAMID: Int
    let FP: Double
    let WP: Int?
    
    enum CodingKeys: CodingKey {
        case xMLBAMID, FP, WP
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.xMLBAMID = try container.decode(Int.self, forKey: .xMLBAMID)
        self.FP = try container.decode(Double.self, forKey: .FP)
        self.WP = try container.decodeIfPresent(Int.self, forKey: .WP)
    }
}

struct FieldingResponse: Decodable {
    let data: [FieldingStats]
}
