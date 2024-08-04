//  Player.swift
//  betMLB
//  Created by Andrew Xin on 8/2/24.

import Foundation

protocol Player: Identifiable, Decodable {
    var id: Int { get }
    var name: String { get }
    var teamName: String { get }
    var teamId: Int { get }
}
