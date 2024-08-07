//  PlayerListView.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import SwiftUI
import SDWebImageSwiftUI

struct PlayerListView: View {
    @State private var viewModel = PlayerListViewVM()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.players, id: \.id) { player in
                    PlayerCardView(player: player)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .onDisappear {
            viewModel.cancelLoadingTasks()
        }
    }
    
    @ViewBuilder func PlayerCardView(player: Player) -> some View {
        HStack {
            // Player's Headshot
            if let image = viewModel.playerImages[player.id] {
                image
                    .resizable()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .frame(width: 90, height: 90)
                    .padding(3)
                    .offset(x: 4.5)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Text("No Image").foregroundColor(.gray))
                    .frame(width: 90, height: 90)
                    .padding(3)
                    .offset(x: 4.5)
            }
            Divider()
                .frame(width: 1, height: 85)
                .background(.black)
            VStack(alignment: .leading, spacing: 4) {
                Text(player.fullName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .offset(y: 3.5)
                // General Stats
                HStack {
                    Text("\(mapTeamIdToAbbreviation(fromId: player.currentTeam.id))")
                        .font(.subheadline)
                    Divider()
                        .frame(width: 5, height: 5)
                        .background(.gray)
                    Text("\(player.primaryPosition.abbreviation)")
                        .font(.subheadline)
                    Divider()
                        .frame(width: 5, height: 5)
                        .background(.gray)
                    Text("#\(player.primaryNumber)")
                        .font(.subheadline)
                }
                Text("Birth Date: \(player.birthDateFormatted ?? player.birthDate) (\(player.currentAge))")
                    .font(.subheadline)
                Text("Bats/Throws: \(player.batSide.code) / \(player.pitchHand.code)")
                    .font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                // Position Bubble
                WebImage(url: URL(string: "https://www.mlbstatic.com/team-logos/\(player.currentTeam.id).svg"))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .scaledToFit()
                    .padding(8)
                Spacer()
                Text(player.primaryPosition.abbreviation)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(width: 20, height: 15)
                    .padding(8)
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.red, lineWidth: 2))
                    .offset(x: -7, y: -7)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    /*
     if let pitchingStats = player.pitchingStats {
     Text("Games: \(pitchingStats.G)")
     .font(.subheadline)
     .foregroundColor(.primary)
     Text("Games Started: \(pitchingStats.GS)")
     .font(.subheadline)
     .foregroundColor(.primary)
     Text("Innings Pitched: \(String(format: "%.2f", pitchingStats.IP))")
     .font(.subheadline)
     .foregroundColor(.primary)
     }
     */
}

#Preview {
    PlayerListView()
}
