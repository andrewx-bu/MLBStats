//  HittingStats.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation

struct HittingStats: Decodable {
    let xMLBAMID: Int
    let Bats: String
    let AVG: Double
}

struct HittingRespone: Decodable {
    let data: [HittingStats]
}
