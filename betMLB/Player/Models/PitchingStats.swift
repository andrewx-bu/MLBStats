//
//  PitchingStats.swift
//  betMLB
//
//  Created by Andrew Xin on 8/5/24.
//

import Foundation

struct PitchingStats: Decodable {
    let xMLBAMID: Int
    let Throws: String
    let ERA: Double
}

struct PitchingResponse: Decodable {
    let data: [PitchingStats]
}
