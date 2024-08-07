//  PlayerCardView.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import SwiftUI

struct PlayerCard: View {
    let player: MockPlayer
    let image: Image?
    
    var body: some View {
        HStack(spacing: 16) {
            // Player's headshot
            if let image = image {
                image
                    .resizable()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .frame(width: 80, height: 80)
                    .padding(8)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(Text("No Image").foregroundColor(.gray))
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Player's name and position
                Text(player.fullName)
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Position: \(player.primaryPosition.abbreviation)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Throw/bat information
                if let throwSide = player.throwSide {
                    Text("Throws: \(throwSide)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let batSide = player.batSide {
                    Text("Bats: \(batSide)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Player's stats
                if let AVG = player.hittingStats?.AVG {
                    Text("AVG: \(AVG)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                if let BABIP = player.pitchingStats?.BABIP {
                    Text("BABIP: \(BABIP)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                if let DEF = player.fieldingStats?.DEF {
                    Text("DEF: \(DEF)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// Sample Player model for demonstration
struct MockPlayer: Identifiable {
    let id: Int
    let fullName: String
    let primaryNumber: Int
    let currentAge: Int
    let currentTeam: String
    let primaryPosition: String
    
    let batSide: String
    let pitchHand: String
    
    let boxscoreName: String
    let initLastName: String
    
    var hittingStats: MockHittingStats?
    var pitchingStats: MockPitchingStats?
    var fieldingStats: MockFieldingStats?
}

struct MockHittingStats {
    let AVG: Double
}

struct MockPitchingStats {
    let ERA: Double
}

struct MockFieldingStats {
    let UZR: Double
}

#Preview {
    PlayerCard(
        player: MockPlayer(
            id: 99, fullName: "Lebron James", primaryNumber: 23, currentAge: 40, currentTeam: "LAL", primaryPosition: "SS", batSide: "R", pitchHand: "R", boxscoreName: "James, L", initLastName: "L James",
            hittingStats: MockHittingStats(AVG: 0.999),
            pitchingStats: MockPitchingStats(ERA: 0.125),
            fieldingStats: MockFieldingStats(UZR: 50.012)
        ),
        image: Image(systemName: "person.fill")
    )
}
