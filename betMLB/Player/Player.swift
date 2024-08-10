//  Player.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

struct Player: Identifiable, Decodable {
    let id: Int                                 // 671096
    var headshotId: Int?                        // 25764 (Fangraphs)
    let fullName: String                        // Andrew Abbott
    let firstName: String
    let lastName: String
    let primaryNumber: String?                  // "41"
    let birthDate: String                       // 1999-06-01
    let birthDateFormatted: String?             // 6/1/1999
    let currentAge: Int                         // 25
    let birthCity: String?                      // Lynchburg
    let birthStateProvince: String?             // VA
    let birthCountry: String                    // USA
    let height: String                          // 6' 0\"
    let weight: Int                             // 192
    
    let currentTeam: Team
    struct Team: Identifiable, Decodable {
        let id: Int                             // 113
        let link: String                        // /api/v1/teams/113
        
        init(id: Int, link: String) {
            self.id = id
            self.link = link
        }
    }
    
    let primaryPosition: Position
    struct Position: Decodable {
        let name: String                        // Pitcher
        let type: String                        // Pitcher
        let abbreviation: String                // P
        
        init(name: String, type: String, abbreviation: String) {
            self.name = name
            self.type = type
            self.abbreviation = abbreviation
        }
    }
    
    let batSide: BatSide
    struct BatSide: Decodable {
        let code: String                        // L
        let description: String                 // Left
        
        init(code: String, description: String) {
            self.code = code
            self.description = description
        }
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
    
    enum CodingKeys: CodingKey {
        case id
        case headshotId
        case fullName, firstName, lastName
        case primaryNumber
        case birthDate
        case currentAge
        case birthCity
        case birthStateProvince
        case birthCountry
        case height
        case weight
        case currentTeam
        case primaryPosition
        case batSide
        case pitchHand
        case boxscoreName
        case initLastName
        case hittingStats
        case pitchingStats
        case fieldingStats
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.headshotId = try container.decodeIfPresent(Int.self, forKey: .headshotId)
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.primaryNumber = try container.decodeIfPresent(String.self, forKey: .primaryNumber)
        self.birthDate = try container.decode(String.self, forKey: .birthDate)
        if let date = birthDate.toDate(withFormat: "yyyy-MM-dd") {
            self.birthDateFormatted = date.formatToMDY()
        } else {
            self.birthDateFormatted = nil
        }
        self.currentAge = try container.decode(Int.self, forKey: .currentAge)
        self.birthCity = try container.decodeIfPresent(String.self, forKey: .birthCity)
        self.birthStateProvince = try container.decodeIfPresent(String.self, forKey: .birthStateProvince)
        self.birthCountry = try container.decode(String.self, forKey: .birthCountry)
        self.height = try container.decode(String.self, forKey: .height)
        self.weight = try container.decode(Int.self, forKey: .weight)
        self.currentTeam = try container.decode(Player.Team.self, forKey: .currentTeam)
        self.primaryPosition = try container.decode(Player.Position.self, forKey: .primaryPosition)
        self.batSide = try container.decode(Player.BatSide.self, forKey: .batSide)
        self.pitchHand = try container.decode(Player.PitchHand.self, forKey: .pitchHand)
        self.boxscoreName = try container.decode(String.self, forKey: .boxscoreName)
        self.initLastName = try container.decode(String.self, forKey: .initLastName)
        self.hittingStats = try container.decodeIfPresent(HittingStats.self, forKey: .hittingStats)
        self.pitchingStats = try container.decodeIfPresent(PitchingStats.self, forKey: .pitchingStats)
        self.fieldingStats = try container.decodeIfPresent(FieldingStats.self, forKey: .fieldingStats)
    }
    init(
        id: Int,
        headshotId: Int? = nil,
        fullName: String,
        firstName: String,
        lastName: String,
        primaryNumber: String,
        birthDate: String,
        birthDateFormatted: String? = nil,
        currentAge: Int,
        birthCity: String? = nil,
        birthStateProvince: String? = nil,
        birthCountry: String,
        height: String,
        weight: Int,
        currentTeam: Team,
        primaryPosition: Position,
        batSide: BatSide,
        pitchHand: PitchHand,
        boxscoreName: String,
        initLastName: String,
        hittingStats: HittingStats? = nil,
        pitchingStats: PitchingStats? = nil,
        fieldingStats: FieldingStats? = nil
    ) {
        self.id = id
        self.headshotId = headshotId
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
        self.primaryNumber = primaryNumber
        self.birthDate = birthDate
        self.birthDateFormatted = birthDateFormatted
        self.currentAge = currentAge
        self.birthCity = birthCity
        self.birthStateProvince = birthStateProvince
        self.birthCountry = birthCountry
        self.height = height
        self.weight = weight
        self.currentTeam = currentTeam
        self.primaryPosition = primaryPosition
        self.batSide = batSide
        self.pitchHand = pitchHand
        self.boxscoreName = boxscoreName
        self.initLastName = initLastName
        self.hittingStats = hittingStats
        self.pitchingStats = pitchingStats
        self.fieldingStats = fieldingStats
    }
}

struct PlayerResponse: Decodable {
    let people: [Player]
}

// Fetching headshot from fangraphs
struct PlayerInfo: Decodable {
    let playerInfo: PlayerDetails
    
    struct PlayerDetails: Identifiable, Decodable {
        let id: Int
        let urlHeadshot: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "MLBAMId"
            case urlHeadshot
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.urlHeadshot = try container.decodeIfPresent(String.self, forKey: .urlHeadshot)
        }
    }
}
