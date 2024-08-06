//  Player.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

struct Player: Identifiable, Decodable {
    let id: Int                                 // 671096
    var headshotId: Int?                        // 25764 (Fangraphs)
    let fullName: String                        // Andrew Abbott
    let primaryNumber: String                   // "41"
    let currentAge: Int                         // 25
    
    let currentTeam: Team
    struct Team: Identifiable, Decodable {
        let id: Int                             // 113
        let link: String                        // /api/v1/teams/113
    }
    
    let primaryPosition: Position
    struct Position: Decodable {
        let name: String                        // Pitcher
        let type: String                        // Pitcher
        let abbreviation: String                // P
    }
    
    let batSide: BatSide
    struct BatSide: Decodable {
        let code: String                        // L
        let description: String                 // Left
    }
    
    let pitchHand: PitchHand
    struct PitchHand: Decodable {
        let code: String                        // L
        let description: String                 // Left
    }
    
    let boxscoreName: String                    // Abbott, A
    let initLastName: String                    // A Abbott
    
    var hittingStats: HittingStats?
    var pitchingStats: PitchingStats?
    var fieldingStats: FieldingStats?
}

struct PlayerResponse: Decodable {
    let people: [Player]
}

// Fetching headshot from fangraphs
struct PlayerInfo: Decodable {
    let playerInfo: PlayerDetails
    
    struct PlayerDetails: Identifiable, Decodable {
        let id: Int
        let urlHeadshot: String
        
        enum CodingKeys: String, CodingKey {
            case id = "MLBAMId"
            case urlHeadshot
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.urlHeadshot = try container.decode(String.self, forKey: .urlHeadshot)
        }
    }
}
