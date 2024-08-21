//  LineScore.swift
//  betMLB
//  Created by Andrew Xin on 8/16/24.

import Foundation

struct LineScore: Decodable {
    let currentInning: Int?                 // 9
    let currentInningOrdinal: String?       // 9th
    let inningState: String?                // Bottom
    
    let innings: [Inning]
    struct Inning: Decodable {
        let num: Int                // 1
        let ordinalNum: String      // "1st"
        let home: InningData
        let away: InningData
        
        struct InningData: Decodable {
            let runs: Int?
            let hits: Int
            let errors: Int
            let leftOnBase: Int
        }
    }
    
    let teams: Team
    struct Team: Decodable {
        let home: TeamData
        let away: TeamData
    
        struct TeamData: Decodable {
            let runs: Int
            let hits: Int
            let errors: Int
            let leftOnBase: Int
            let isWinner: Bool?
        }
    }
    
    let defense: Defense
    struct Defense: Decodable {
        let pitcher: LivePlayer?
        let catcher: LivePlayer?
        let first: LivePlayer?
        let second: LivePlayer?
        let third: LivePlayer?
        let shortstop: LivePlayer?
        let left: LivePlayer?
        let center: LivePlayer?
        let right: LivePlayer?
        let batter: LivePlayer?
        let onDeck: LivePlayer?
        let inHole: LivePlayer?
        let battingOrder: Int?
        let team: LiveTeam
    }
    
    let offense: Offense
    struct Offense: Decodable {
        let batter: LivePlayer?
        let onDeck: LivePlayer?
        let inHole: LivePlayer?
        let pitcher: LivePlayer?
        let battingOrder: Int?
        let team: LiveTeam
    }
    
    struct LivePlayer: Identifiable, Decodable {
        let id: Int
        let fullName: String
        let link: String
    }
    
    struct LiveTeam: Identifiable, Decodable {
        let id: Int
        let name: String
        let link: String
    }
    
    let balls: Int?
    let strikes: Int?
    let outs: Int?
}
