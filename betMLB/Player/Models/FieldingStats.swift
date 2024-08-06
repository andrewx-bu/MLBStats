//  FieldingStats.swift
//  betMLB
//  Created by Andrew Xin on 8/5/24.

import Foundation

struct FieldingStats: Decodable {
    let xMLBAMID: Int
    let FP: Double
    let WP: Int?
    
    enum CodingKeys: CodingKey {
        case xMLBAMID, FP, WP
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.xMLBAMID = try container.decode(Int.self, forKey: .xMLBAMID)
        self.FP = try container.decode(Double.self, forKey: .FP)
        self.WP = try container.decodeIfPresent(Int.self, forKey: .WP)
    }
}

struct FieldingResponse: Decodable {
    let data: [FieldingStats]
}
