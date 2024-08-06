//
//  PitchingStats.swift
//  betMLB
//
//  Created by Andrew Xin on 8/5/24.
//

import Foundation

struct PitchingStats: Identifiable, Decodable {
    let id: Int                 // 554430
    let playerid: Int           // 25764 (Fangraphs)
    
    // General Stats
    let W: Int                  // Wins
    let L: Int                  // Losses
    let ERA: Double             // Earned Runs AVG
    let WHIP: Double            // Walks and Hits per Inning Pitched
    let G: Int                  // Games Played
    let GS: Int                 // Games Started
    let SV: Int                 // Saves
    let HLD: Int                // Holds
    let BS: Int                 // Blown Saves
    let IP: Double              // Innings Pitched
    let TBF: Int                // Total Batters Faced
    let H: Int                  // Hits
    let R: Int                  // Runs
    let ER: Int                 // Earned Runs
    let HR: Int                 // Home Runs
    let BB: Int                 // Walks
    let IBB: Int                // Intentional Walks
    let HBP: Int                // Hit By Pitches
    let WP: Int                 // Wild Pitches
    let SO: Int                 // Strikeouts
    let AVG: Double             // Batting AVG
    
    // Ball Data
    let pitches: Int            // 8679
    let balls: Int              // 2940
    let strikes: Int            // 5739
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
    let iffbPCT: Double         // Infield Fly Ball PCT
    let ifhPCT: Double          // Infield Hit PCT
    let buhPCT: Double          // Bunt Hit PCT
    let ttoPCT: Double          // Three Total Outcomes PCT
    let HRperFB: Double         // Home Run/Fly Ball
    
    // Per 9 Inning Stats
    let Kper9: Double           // Strikeouts/9 Innings
    let BBper9: Double          // Walks/9 Innings
    let Hper9: Double           // Hits/9 Innings
    let HRper9: Double          // Home Runs/9 Innings
    let RSper9: Double          // Run Support/9 Innings
    
    // Advanced Stats
    let BABIP: Double           // Batting AVG on Balls in Play
    let KperBB: Double          // Strikeouts/Walks
    let kPCT: Double            // Strikeout PCT
    let bbPCT: Double           // Walk PCT
    let lobPCT: Double          // Left on Base PCT
    let RS: Int                 // Run Support
    let SIERA: Double           // Skill Interactive ERA
    let FIP: Double             // Fielding Independent Pitching
    let xFIP: Double            // Expected Fielding Independent Pitching
    let kwERA: Double           // Earned Run AVG on Strikeouts and Walks       - FanGraphs
    let tERA: Double            // True Earned Run AVG
    let WAR: Double             // Wins Above Replacement
    
    // Minus Stats
    let ERAminus: Double        // Earned Runs AVG -                            - FanGraphs
    let FIPminus: Double        // Field Independent Pitching -                 - Fangraphs
    let xFIPminus: Double       // Expected Field Independent Pitching -        - Fangraphs
    // Plus Stats
    let Kper9plus: Double       // Strikeout/9 Innings +
    let BBper9plus: Double      // Walks/9 Innings +
    let KperBBplus: Double      // Strikeouts/Walks +
    let Hper9plus: Double       // Hits/9 Innings +
    let HRper9plus: Double      // HR/9 Innings +
    let AVGplus: Double         // Batting AVG +
    let WHIPplus: Double        // Walks and Hits per Inning Pitched +
    let BABIPplus: Double       // Batting AVG on Balls in Play +
    let lobPCTplus: Double      // Left on Base PCT +
    let kPCTplus: Double        // Strikeout PCT +
    let bbPCTplus: Double       // Walk PCT +
    let ldPCTplus: Double       // Line Drive PCT +
    let gbPCTplus: Double       // Ground Ball PCT +
    let fbPCTplus: Double       // Fly Ball PCT +
    let HRperFBpctPLUS: Double  // Home Runs/Fly Balls PCT +
    
    enum CodingKeys: String, CodingKey {
        case id = "xMLBAMID"
        case playerid
        case W, L, ERA, WHIP, G, GS, SV, HLD, BS, IP, TBF, H, R, ER, HR, BB, IBB, HBP, WP, SO, AVG
        case pitches = "Pitches"
        case balls = "Balls"
        case strikes = "Strikes"
        case GB, FB, LD, IFFB, IFH, BU, BUH
        case GBperFB = "GB/FB"
        case ldPCT = "LD%"
        case gbPCT = "GB%"
        case fbPCT = "FB%"
        case iffbPCT = "IFFB%"
        case ifhPCT = "IFH%"
        case buhPCT = "BUH%"
        case ttoPCT = "TTO%"
        case HRperFB = "HR/FB"
        case Kper9 = "K/9"
        case BBper9 = "BB/9"
        case Hper9 = "H/9"
        case HRper9 = "HR/9"
        case RSper9 = "RS/9"
        case BABIP
        case KperBB = "K/BB"
        case kPCT = "K%"
        case bbPCT = "BB%"
        case lobPCT = "LOB%"
        case RS, SIERA, FIP, xFIP, kwERA, tERA, WAR
        case ERAminus = "ERA-"
        case FIPminus = "FIP-"
        case xFIPminus = "xFIP-"
        case Kper9plus = "K/9+"
        case BBper9plus = "BB/9+"
        case KperBBplus = "K/BB+"
        case Hper9plus = "H/9+"
        case HRper9plus = "HR/9+"
        case AVGplus = "AVG+"
        case WHIPplus = "WHIP+"
        case BABIPplus = "BABIP+"
        case lobPCTplus = "LOB%+"
        case kPCTplus = "K%+"
        case bbPCTplus = "BB%+"
        case ldPCTplus = "LD%+"
        case gbPCTplus = "GB%+"
        case fbPCTplus = "FB%+"
        case HRperFBpctPLUS = "HRFB%+"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.playerid = try container.decode(Int.self, forKey: .playerid)
        self.W = try container.decode(Int.self, forKey: .W)
        self.L = try container.decode(Int.self, forKey: .L)
        self.ERA = try container.decode(Double.self, forKey: .ERA)
        self.WHIP = try container.decode(Double.self, forKey: .WHIP)
        self.G = try container.decode(Int.self, forKey: .G)
        self.GS = try container.decode(Int.self, forKey: .GS)
        self.SV = try container.decode(Int.self, forKey: .SV)
        self.HLD = try container.decode(Int.self, forKey: .HLD)
        self.BS = try container.decode(Int.self, forKey: .BS)
        self.IP = try container.decode(Double.self, forKey: .IP)
        self.TBF = try container.decode(Int.self, forKey: .TBF)
        self.H = try container.decode(Int.self, forKey: .H)
        self.R = try container.decode(Int.self, forKey: .R)
        self.ER = try container.decode(Int.self, forKey: .ER)
        self.HR = try container.decode(Int.self, forKey: .HR)
        self.BB = try container.decode(Int.self, forKey: .BB)
        self.IBB = try container.decode(Int.self, forKey: .IBB)
        self.HBP = try container.decode(Int.self, forKey: .HBP)
        self.WP = try container.decode(Int.self, forKey: .WP)
        self.SO = try container.decode(Int.self, forKey: .SO)
        self.AVG = try container.decode(Double.self, forKey: .AVG)
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
        self.iffbPCT = try container.decode(Double.self, forKey: .iffbPCT)
        self.ifhPCT = try container.decode(Double.self, forKey: .ifhPCT)
        self.buhPCT = try container.decode(Double.self, forKey: .buhPCT)
        self.ttoPCT = try container.decode(Double.self, forKey: .ttoPCT)
        self.HRperFB = try container.decode(Double.self, forKey: .HRperFB)
        self.Kper9 = try container.decode(Double.self, forKey: .Kper9)
        self.BBper9 = try container.decode(Double.self, forKey: .BBper9)
        self.Hper9 = try container.decode(Double.self, forKey: .Hper9)
        self.HRper9 = try container.decode(Double.self, forKey: .HRper9)
        self.RSper9 = try container.decode(Double.self, forKey: .RSper9)
        self.BABIP = try container.decode(Double.self, forKey: .BABIP)
        self.KperBB = try container.decode(Double.self, forKey: .KperBB)
        self.kPCT = try container.decode(Double.self, forKey: .kPCT)
        self.bbPCT = try container.decode(Double.self, forKey: .bbPCT)
        self.lobPCT = try container.decode(Double.self, forKey: .lobPCT)
        self.RS = try container.decode(Int.self, forKey: .RS)
        self.SIERA = try container.decode(Double.self, forKey: .SIERA)
        self.FIP = try container.decode(Double.self, forKey: .FIP)
        self.xFIP = try container.decode(Double.self, forKey: .xFIP)
        self.kwERA = try container.decode(Double.self, forKey: .kwERA)
        self.tERA = try container.decode(Double.self, forKey: .tERA)
        self.WAR = try container.decode(Double.self, forKey: .WAR)
        self.ERAminus = try container.decode(Double.self, forKey: .ERAminus)
        self.FIPminus = try container.decode(Double.self, forKey: .FIPminus)
        self.xFIPminus = try container.decode(Double.self, forKey: .xFIPminus)
        self.Kper9plus = try container.decode(Double.self, forKey: .Kper9plus)
        self.BBper9plus = try container.decode(Double.self, forKey: .BBper9plus)
        self.KperBBplus = try container.decode(Double.self, forKey: .KperBBplus)
        self.Hper9plus = try container.decode(Double.self, forKey: .Hper9plus)
        self.HRper9plus = try container.decode(Double.self, forKey: .HRper9plus)
        self.AVGplus = try container.decode(Double.self, forKey: .AVGplus)
        self.WHIPplus = try container.decode(Double.self, forKey: .WHIPplus)
        self.BABIPplus = try container.decode(Double.self, forKey: .BABIPplus)
        self.lobPCTplus = try container.decode(Double.self, forKey: .lobPCTplus)
        self.kPCTplus = try container.decode(Double.self, forKey: .kPCTplus)
        self.bbPCTplus = try container.decode(Double.self, forKey: .bbPCTplus)
        self.ldPCTplus = try container.decode(Double.self, forKey: .ldPCTplus)
        self.gbPCTplus = try container.decode(Double.self, forKey: .gbPCTplus)
        self.fbPCTplus = try container.decode(Double.self, forKey: .fbPCTplus)
        self.HRperFBpctPLUS = try container.decode(Double.self, forKey: .HRperFBpctPLUS)
    }
}

struct PitchingResponse: Decodable {
    let data: [PitchingStats]
}
