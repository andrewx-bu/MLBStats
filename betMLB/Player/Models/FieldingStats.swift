//  FieldingStats.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation

struct FieldingStats: Identifiable, Decodable {
    let id: Int             // 677951
    let name: String        // "<a href="statss.aspx?playerid=25764&position=SS">Bobby Witt Jr.</a>"
    
    // General Stats
    let G: Int              // Games Played
    let inn: Double         // Innings Played
    let PO: Int             // Putouts
    let A: Int              // Assists
    let E: Int              // Errors
    let DP: Int             // Double Plays? This stat seems off
    let FP: Double          // Fielding PCT
    
    // Advanced Stats
    let DRS: Int?           // Defensive Runs Saved
    let UZR: Double?        // Ultimate Zone Rating
    let UZRper150: Double?  // UZR per 150 Games                - FanGraphs
    let DEF: Double         // Defensive Runs Above AVG         - FanGraphs
    let OAA: Int?           // Outs Above AVG                   - Statcast
    let FRV: Int?           // Fielding Run Value               - Statcast
    
    // Catcher-Specific Stats
    let SB: Int?            // Stolen Bases
    let CS: Int?            // Caught Stealing
    let PB: Int?            // Passed Balls
    let WP: Int?            // Wild Pitches
    let FRM: Double?        // Catcher Framing                  - Statcast
    
    enum CodingKeys: String, CodingKey {
        case id = "xMLBAMID"
        case name = "Name"
        case G
        case inn = "Inn"
        case PO, A, E, DP, FP, DRS, UZR
        case UZRper150 = "UZR/150"
        case DEF = "Defense"
        case OAA
        case FRV = "FRP"
        case SB, CS, PB, WP
        case FRM = "CFraming"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.G = try container.decode(Int.self, forKey: .G)
        self.inn = try container.decode(Double.self, forKey: .inn)
        self.PO = try container.decode(Int.self, forKey: .PO)
        self.A = try container.decode(Int.self, forKey: .A)
        self.E = try container.decode(Int.self, forKey: .E)
        self.DP = try container.decode(Int.self, forKey: .DP)
        self.FP = try container.decode(Double.self, forKey: .FP)
        self.DRS = try container.decodeIfPresent(Int.self, forKey: .DRS)
        self.UZR = try container.decodeIfPresent(Double.self, forKey: .UZR)
        self.UZRper150 = try container.decodeIfPresent(Double.self, forKey: .UZRper150)
        self.DEF = try container.decode(Double.self, forKey: .DEF)
        self.OAA = try container.decodeIfPresent(Int.self, forKey: .OAA)
        self.FRV = try container.decodeIfPresent(Int.self, forKey: .FRV)
        self.SB = try container.decodeIfPresent(Int.self, forKey: .SB)
        self.CS = try container.decodeIfPresent(Int.self, forKey: .CS)
        self.PB = try container.decodeIfPresent(Int.self, forKey: .PB)
        self.WP = try container.decodeIfPresent(Int.self, forKey: .WP)
        self.FRM = try container.decodeIfPresent(Double.self, forKey: .FRM)
    }
}

struct FieldingResponse: Decodable {
    let data: [FieldingStats]
}
