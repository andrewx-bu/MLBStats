//  DetailPlayerViewVM.swift
//  betMLB
//  Created by Andrew Xin on 8/8/24.

import Foundation
import SwiftUI

@Observable class DetailPlayerViewVM {
    var player: Player
    var image: Image?
    
    init(player: Player, image: Image?) {
        self.player = player
        self.image = image
    }
}
