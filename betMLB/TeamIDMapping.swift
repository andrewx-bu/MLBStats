//  TeamIDMapping.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation

// Dictionary mapping statsAPI's teamIDs to fangraphAPI's
let teamIdMapping: [Int: Int] = [
    108: 1,     // LAA
    109: 15,    // ARI
    110: 2,     // BAL
    111: 3,     // BOS
    112: 17,    // CHC
    113: 18,    // CIN
    114: 5,     // CLE
    115: 19,    // COL
    116: 6,     // DET
    117: 21,    // HOU
    118: 7,     // KC - KCR
    119: 22,    // LAD
    120: 24,    // WSH - WSN
    121: 25,    // NYM
    133: 10,    // OAK
    134: 27,    // PIT
    135: 29,    // SD - SDP
    136: 11,    // SEA
    137: 30,    // SF - SFG
    138: 28,    // STL
    139: 12,    // TB - TBR
    140: 13,    // TEX
    141: 14,    // TOR
    142: 8,     // MIN
    143: 26,    // PHI
    144: 16,    // ATL
    145: 4,     // CWS - CHW
    146: 20,    // MIA
    147: 9,     // NYY
    158: 23     // MIL
]

// Maps statsAPI's teamIDs to abbreviations
let teamAbbreviationMapping: [Int: String] = [
    108: "LAA",    // Los Angeles Angels
    109: "ARI",    // Arizona Diamondbacks
    110: "BAL",    // Baltimore Orioles
    111: "BOS",    // Boston Red Sox
    112: "CHC",    // Chicago Cubs
    113: "CIN",    // Cincinnati Reds
    114: "CLE",    // Cleveland Guardians
    115: "COL",    // Colorado Rockies
    116: "DET",    // Detroit Tigers
    117: "HOU",    // Houston Astros
    118: "KC",     // Kansas City Royals
    119: "LAD",    // Los Angeles Dodgers
    120: "WSH",    // Washington Nationals
    121: "NYM",    // New York Mets
    133: "OAK",    // Oakland Athletics
    134: "PIT",    // Pittsburgh Pirates
    135: "SD",     // San Diego Padres
    136: "SEA",    // Seattle Mariners
    137: "SF",     // San Francisco Giants
    138: "STL",    // St. Louis Cardinals
    139: "TB",     // Tampa Bay Rays
    140: "TEX",    // Texas Rangers
    141: "TOR",    // Toronto Blue Jays
    142: "MIN",    // Minnesota Twins
    143: "PHI",    // Philadelphia Phillies
    144: "ATL",    // Atlanta Braves
    145: "CWS",    // Chicago White Sox
    146: "MIA",    // Miami Marlins
    147: "NYY",    // New York Yankees
    158: "MIL"     // Milwaukee Brewers
]

var reverseTeamIdMapping: [Int: Int] = {
    Dictionary(uniqueKeysWithValues: teamIdMapping.map { ($1, $0) })
}()

func mapTeamId(fromStatsAPI id: Int) -> Int? {
    return teamIdMapping[id]
}

func mapTeamId(fromFanGraphsAPI id: Int) -> Int? {
    return reverseTeamIdMapping[id]
}

func mapTeamIdToAbbreviation(fromId id: Int) -> String {
    return teamAbbreviationMapping[id] ?? "N/A"
}
