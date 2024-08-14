//  Schedule.swift
//  betMLB
//  Created by Andrew Xin on 8/13/24.

import Foundation

struct ScheduleDate: Decodable {
    let date: String                                // 2024-07-08
    let totalGames: Int                             // 7
    let totalGamesInProgress: Int                   // 0
    let games: [Game]
    
    struct Game: Decodable {
        let gamePk: Int                             // 745480
        let link: String                            // /api/v1.1/game/745480/feed/live
        let gameType: String                        // R
        let gameDate: String                        // 2024-07-08T16:35:00Z
        let status: GameStatus
        struct GameStatus: Decodable {
            let detailedState: String               // In Progress
        }
        
        let teams: Teams
        struct Teams: Decodable {
            let away: TeamInfo
            let home: TeamInfo
            
            struct TeamInfo: Decodable {
                let leagueRecord: LeagueRecord
                struct LeagueRecord: Decodable {
                    let wins: Int                   // 44
                    let losses: Int                 // 45
                    let pct: String                 // .494
                }
                
                let score: Int?                     // 2 - 0 if game is scheduled (yet to start)
                let team: Team
                struct Team: Decodable {
                    let id: Int                     // 121
                    let name: String                // "New York Mets"
                    let link: String                // /api/v1/teams/121
                }
            }
        }
        
        let venue: Venue
        struct Venue: Decodable {
            let id: Int                             // 31
            let name: String                        // PNC Park
            let link: String                        // /api/v1/venues/31
        }
        
        let content: Content
        struct Content: Decodable {
            let link: String                        // /api/v1/game/745480/content
        }

        let gameNumber: Int
        let doubleHeader: String
        let dayNight: String
        let gamesInSeries: Int
    }
}

struct ScheduleResponse: Decodable {
    let dates: [ScheduleDate]
}
