//  Team.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import Foundation

struct Team: Identifiable, Decodable {
    let id: Int
    let name: String
    let link: String
    
    let venue: Venue
    struct Venue: Identifiable, Decodable {
        let id: Int
        let name: String
    }
    
    let abbreviation: String
    
    let league: League
    struct League: Identifiable, Decodable {
        let id: Int
        let name: String
    }
    
    let division: Division
    struct Division: Identifiable, Decodable {
        let id: Int
        let name: String
    }
    
    var hittingStats: HittingStats?
    var pitchingStats: PitchingStats?
    var fieldingStats: FieldingStats?
}

struct TeamResponse: Decodable {
    let teams: [Team]
}
