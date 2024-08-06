//  HittingStats.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation

struct HittingStats: Identifiable, Decodable {
    let id: Int                 // 592450
    let name: String            // "<a href="statss.aspx?playerid=25764&position=SS">Bobby Witt Jr.</a>"
    
    // General Stats
    let G: Int                  // Games Played
    let AB: Int                 // At Bats
    let PA: Int                 // Plate Appearances
    let H: Int                  // Hits
    let singles: Int            // 1B
    let doubles: Int            // 2B
    let triples: Int            // 3B
    let HR: Int                 // Home Runs
    let R: Int                  // Runs
    let RBI: Int                // Runs Batted In
    let BB: Int                 // Walks
    let IBB: Int                // Intentional Walks
    let SO: Int                 // Strikeouts
    let HBP: Int                // Hit By Pitches
    let SF: Int                 // Sacrifice Flies
    let SH: Int                 // Sacrifice Hits
    let GDP: Int                // Grounded into Double Play
    let SB: Int                 // Stolen Bases
    let CS: Int                 // Caught Stealind
    let AVG: Double             // Batting AVG
    let OBP: Double             // On Base PCT
    let SLG: Double             // Slugging
    let OPS: Double             // On Base + Slugging
    
    // Ball Data
    let pitches: Int            // 4968
    let balls: Int              // 2131
    let strikes: Int            // 2837
    let GB: Int                 // Ground Balls
    let FB: Int                 // Fly Balls
    let LD: Int                 // Line Drives
    let IFFB: Int               // Infield Fly Balls
    let IFH: Int                // Infield Hits
    let BU: Int                 // Bunts
    let BUH: Int                // Bunt Hits
    let GBperFB: Double         // Ground Balls/Fly Balls
    let ldPCT: Double           // Line Drive PCT
    let gbPCT: Double           // Ground Ball PCT
    let fbPCT: Double           // Fly Ball PCT
    let iffpPCT: Double         // Infield Fly Ball PCT
    let ifhPCT: Double          // Infield Hit PCT
    let buhPCT: Double          // Bunt Hit PCT
    let ttoPCT: Double          // Three Total Outcomes PCT
    let HRperFB: Double         // Home Runs/Fly Balls
    
    // Advanced Stats
    let bbPCT: Double           // Walk PCT
    let kPCT: Double            // Strikeout PCT
    let BBperK: Double          // Walks/Strikeouts
    let ISO: Double             // Isolated Power
    let BABIP: Double           // Batting AVG on Balls in Play
    let wOBA: Double            // Weighted On Base AVG
    let wRAA: Double            // Runs Above AVG
    let wRC: Double             // Runs Created
    let WAR: Double             // Wins Above Replacement
    
    // Plus Stats
    let wRCplus: Double         // Runs Created +
    let AVGplus: Double         // Batting AVG +
    let bbPCTplus: Double       // Walk PCT +
    let kPCTplus: Double        // Strikeout PCT +
    let OBPplus: Double         // On Base Percentage +
    let SLGplus: Double         // Slugging +
    let ISOplus: Double         // Isolated Power +
    let BABIPplus: Double       // Batting AVG on Balls in Play +
    let ldPCTplus: Double       // Line Drive PCT +
    let gbPCTplus: Double       // Ground Ball PCT +
    let fbPCTplus: Double       // Fly Ball PCT +
    let HRperFBpctPLUS: Double  // Home Runs/Fly Balls PCT +
    
    enum CodingKeys: String, CodingKey {
        case id = "xMLBAMID"
        case name = "Name"
        case G, AB, PA, H
        case singles = "1B"
        case doubles = "2B"
        case triples = "3B"
        case HR, R, RBI, BB, IBB, SO, HBP, SF, SH, GDP, SB, CS, AVG, OBP, SLG, OPS
        case pitches = "Pitches"
        case balls = "Balls"
        case strikes = "Strikes"
        case GB, FB, LD, IFFB, IFH, BU, BUH
        case GBperFB = "GB/FB"
        case ldPCT = "LD%"
        case gbPCT = "GB%"
        case fbPCT = "FB%"
        case iffpPCT = "IFFB%"
        case ifhPCT = "IFH%"
        case buhPCT = "BUH%"
        case ttoPCT = "TTO%"
        case HRperFB = "HR/FB"
        case bbPCT = "BB%"
        case kPCT = "K%"
        case BBperK = "BB/K"
        case ISO, BABIP, wOBA, wRAA, wRC, WAR
        case wRCplus = "wRC+"
        case AVGplus = "AVG+"
        case bbPCTplus = "BB%+"
        case kPCTplus = "K%+"
        case OBPplus = "OBP+"
        case SLGplus = "SLG+"
        case ISOplus = "ISO+"
        case BABIPplus = "BABIP+"
        case ldPCTplus = "LD%+"
        case gbPCTplus = "GB%+"
        case fbPCTplus = "FB%+"
        case HRperFBpctPLUS = "HRFB%+"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.G = try container.decode(Int.self, forKey: .G)
        self.AB = try container.decode(Int.self, forKey: .AB)
        self.PA = try container.decode(Int.self, forKey: .PA)
        self.H = try container.decode(Int.self, forKey: .H)
        self.singles = try container.decode(Int.self, forKey: .singles)
        self.doubles = try container.decode(Int.self, forKey: .doubles)
        self.triples = try container.decode(Int.self, forKey: .triples)
        self.HR = try container.decode(Int.self, forKey: .HR)
        self.R = try container.decode(Int.self, forKey: .R)
        self.RBI = try container.decode(Int.self, forKey: .RBI)
        self.BB = try container.decode(Int.self, forKey: .BB)
        self.IBB = try container.decode(Int.self, forKey: .IBB)
        self.SO = try container.decode(Int.self, forKey: .SO)
        self.HBP = try container.decode(Int.self, forKey: .HBP)
        self.SF = try container.decode(Int.self, forKey: .SF)
        self.SH = try container.decode(Int.self, forKey: .SH)
        self.GDP = try container.decode(Int.self, forKey: .GDP)
        self.SB = try container.decode(Int.self, forKey: .SB)
        self.CS = try container.decode(Int.self, forKey: .CS)
        self.AVG = try container.decode(Double.self, forKey: .AVG)
        self.OBP = try container.decode(Double.self, forKey: .OBP)
        self.SLG = try container.decode(Double.self, forKey: .SLG)
        self.OPS = try container.decode(Double.self, forKey: .OPS)
        self.pitches = try container.decode(Int.self, forKey: .pitches)
        self.balls = try container.decode(Int.self, forKey: .balls)
        self.strikes = try container.decode(Int.self, forKey: .strikes)
        self.GB = try container.decode(Int.self, forKey: .GB)
        self.FB = try container.decode(Int.self, forKey: .FB)
        self.LD = try container.decode(Int.self, forKey: .LD)
        self.IFFB = try container.decode(Int.self, forKey: .IFFB)
        self.IFH = try container.decode(Int.self, forKey: .IFH)
        self.BU = try container.decode(Int.self, forKey: .BU)
        self.BUH = try container.decode(Int.self, forKey: .BUH)
        self.GBperFB = try container.decode(Double.self, forKey: .GBperFB)
        self.ldPCT = try container.decode(Double.self, forKey: .ldPCT)
        self.gbPCT = try container.decode(Double.self, forKey: .gbPCT)
        self.fbPCT = try container.decode(Double.self, forKey: .fbPCT)
        self.iffpPCT = try container.decode(Double.self, forKey: .iffpPCT)
        self.ifhPCT = try container.decode(Double.self, forKey: .ifhPCT)
        self.buhPCT = try container.decode(Double.self, forKey: .buhPCT)
        self.ttoPCT = try container.decode(Double.self, forKey: .ttoPCT)
        self.HRperFB = try container.decode(Double.self, forKey: .HRperFB)
        self.bbPCT = try container.decode(Double.self, forKey: .bbPCT)
        self.kPCT = try container.decode(Double.self, forKey: .kPCT)
        self.BBperK = try container.decode(Double.self, forKey: .BBperK)
        self.ISO = try container.decode(Double.self, forKey: .ISO)
        self.BABIP = try container.decode(Double.self, forKey: .BABIP)
        self.wOBA = try container.decode(Double.self, forKey: .wOBA)
        self.wRAA = try container.decode(Double.self, forKey: .wRAA)
        self.wRC = try container.decode(Double.self, forKey: .wRC)
        self.WAR = try container.decode(Double.self, forKey: .WAR)
        self.wRCplus = try container.decode(Double.self, forKey: .wRCplus)
        self.AVGplus = try container.decode(Double.self, forKey: .AVGplus)
        self.bbPCTplus = try container.decode(Double.self, forKey: .bbPCTplus)
        self.kPCTplus = try container.decode(Double.self, forKey: .kPCTplus)
        self.OBPplus = try container.decode(Double.self, forKey: .OBPplus)
        self.SLGplus = try container.decode(Double.self, forKey: .SLGplus)
        self.ISOplus = try container.decode(Double.self, forKey: .ISOplus)
        self.BABIPplus = try container.decode(Double.self, forKey: .BABIPplus)
        self.ldPCTplus = try container.decode(Double.self, forKey: .ldPCTplus)
        self.gbPCTplus = try container.decode(Double.self, forKey: .gbPCTplus)
        self.fbPCTplus = try container.decode(Double.self, forKey: .fbPCTplus)
        self.HRperFBpctPLUS = try container.decode(Double.self, forKey: .HRperFBpctPLUS)
    }
}

struct HittingRespone: Decodable {
    let data: [HittingStats]
}
