//  TeamIDMapping.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import Foundation
import SwiftUI

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

let teamColors: [String: [Color]] = [
    "ARI": [Color(hex: "#A71930"), Color(hex: "#E3D4AD")], // Arizona Diamondbacks
    "ATL": [Color(hex: "#CE1141"), Color(hex: "#13274F")], // Atlanta Braves
    "BAL": [Color(hex: "#DF4601"), Color(hex: "#000000")], // Baltimore Orioles
    "BOS": [Color(hex: "#BD3039"), Color(hex: "#0C2340")], // Boston Red Sox
    "CHC": [Color(hex: "#0E3386"), Color(hex: "#CC3433")], // Chicago Cubs
    "CIN": [Color(hex: "#C6011F"), Color(hex: "#000000")], // Cincinnati Reds
    "CLE": [Color(hex: "#00385D"), Color(hex: "#E50022")], // Cleveland Guardians
    "COL": [Color(hex: "#333366"), Color(hex: "#C4CED4")], // Colorado Rockies
    "CWS": [Color(hex: "#27251F"), Color(hex: "#C4CED4")], // Chicago White Sox
    "DET": [Color(hex: "#0C2340"), Color(hex: "#FA4616")], // Detroit Tigers
    "HOU": [Color(hex: "#002D62"), Color(hex: "#EB6E1F")], // Houston Astros
    "KC": [Color(hex: "#004687"), Color(hex: "#BD9B60")], // Kansas City Royals
    "LAD": [Color(hex: "#005A9C"), Color(hex: "EF3E42")], // Los Angeles Dodgers
    "LAA": [Color(hex: "#003263"), Color(hex:"862633")], // Los Angeles Angels
    "MIA": [Color(hex: "#00A3E0"), Color(hex: "#000000")], // Miami Marlins
    "MIL": [Color(hex: "#12284B"), Color(hex: "#FFC52F")], // Milwaukee Brewers
    "MIN": [Color(hex: "#002B5C"), Color(hex: "#D31145")], // Minnesota Twins
    "NYM": [Color(hex: "#002D72"), Color(hex: "#FF5910")], // New York Mets
    "NYY": [Color(hex: "#003087"), Color(hex: "#E4002C")], // New York Yankees
    "OAK": [Color(hex: "#003831"), Color(hex: "#EFB21E")], // Oakland Athletics
    "PHI": [Color(hex: "#E81828"), Color(hex: "002D72")], // Philadelphia Phillies
    "PIT": [Color(hex: "#27251F"), Color(hex: "#FDB827")], // Pittsburgh Pirates
    "SD": [Color(hex: "#2F241D"), Color(hex: "#FFC425")], // San Diego Padres
    "SEA": [Color(hex: "#0C2C56"), Color(hex: "#005C5C")], // Seattle Mariners
    "SF": [Color(hex: "#FD5A1E"), Color(hex: "#27251F")], // San Francisco Giants
    "STL": [Color(hex: "#C41E3A"), Color(hex: "#0C2340")], // St. Louis Cardinals
    "TB": [Color(hex: "#092C5C"), Color(hex: "#8FBCE6")], // Tampa Bay Rays
    "TEX": [Color(hex: "#003278"), Color(hex: "#C0111F")], // Texas Rangers
    "TOR": [Color(hex: "#134A8E"), Color(hex: "#1D2D5C")], // Toronto Blue Jays
    "WSH": [Color(hex: "#AB0003"), Color(hex: "#14225A")] // Washington Nationals
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

func teamColors(forAbbreviation abbreviation: String) -> [Color] {
    return teamColors[abbreviation] ?? []
}
