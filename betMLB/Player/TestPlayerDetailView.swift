//  TestPlayerDetailView.swift
//  betMLB
//  Created by Andrew Xin on 8/8/24.

import SwiftUI
import SDWebImageSwiftUI

struct TestPlayerDetailView: View {
    let player: MockPlayer = MockPlayer(
        id: 671096,
        headshotId: nil,
        fullName: "Andrew Abbott",
        firstName: "Andrew",
        lastName: "Abbott",
        primaryNumber: "41",
        birthDate: "1999-06-01",
        birthDateFormatted: "6/1/1999",
        currentAge: 25,
        birthCity: "Lynchburg",
        birthStateProvince: "VA",
        birthCountry: "USA",
        height: "6' 0\"",
        weight: 192,
        currentTeam: 113,
        primaryPosition: "Pitcher",
        batSide: "R",
        pitchHand: "R",
        boxscoreName: "Abbott, A",
        initLastName: "A Abbott"
    )
    
    let columns = [
        GridItem(.flexible(maximum: 75)),
        GridItem(.flexible(maximum: 30)),
        GridItem(.flexible(maximum: 75)),
        GridItem(.flexible(maximum: 30)),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Player Details
            HStack {
                VStack(alignment: .leading, spacing: -4) {
                    Text(player.firstName.uppercased())
                        .font(.title.bold())
                    Text(player.lastName.uppercased())
                        .font(.title.bold())
                    Text("#\(player.primaryNumber) \(player.primaryPosition)")
                        .font(.footnote.bold())
                    WebImage(url: URL(string: "https://www.mlbstatic.com/team-logos/\(player.currentTeam).svg"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                .padding(.leading, 5)
                Spacer()
            }
            .border(.red)
            ZStack {
                HStack {
                    Spacer()
                    // https://www.pngkey.com/png/full/765-7656718_avatar-blank-person.png
                    // https://images.fangraphs.com/nobg_small_22876646.png
                    WebImage(url: URL(string: "https://images.fangraphs.com/nobg_small_22876646.png"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 225, height: 225)
                }
                .border(.green)
                .padding(.top, -100)
                HStack {
                    VStack(alignment: .leading) {
                        Text("2024")
                            .font(.caption.bold())
                            .padding(.leading, 10)
                        LazyVGrid(columns: columns) {
                            if player.primaryPosition == "Pitcher" {
                                Text("AVG")
                                    .font(.caption.bold())
                                Text("HR")
                                    .font(.caption.bold())
                                Text("RBI")
                                    .font(.caption.bold())
                                Text("R")
                                    .font(.caption.bold())
                                Text(".241")
                                    .font(.caption.bold())
                                Text("19")
                                    .font(.caption.bold())
                                Text("3423")
                                    .font(.caption.bold())
                                Text("343")
                                    .font(.caption.bold())
                            }
                        }
                    }
                    .border(.indigo)
                    .frame(width: UIScreen.main.bounds.width / 2.5)
                    .padding(.bottom, 40)
                    Spacer()
                }
            }
            Divider()
                .frame(width: 360, height: 2)
                .background(.black)
            Spacer()
        }
        .border(.blue)
        .padding()
    }
}

#Preview {
    TestPlayerDetailView()
}

struct MockPlayer: Identifiable {
    let id: Int
    var headshotId: Int?
    let fullName: String
    let firstName: String
    let lastName: String
    let primaryNumber: String
    let birthDate: String
    let birthDateFormatted: String?
    let currentAge: Int
    let birthCity: String?
    let birthStateProvince: String?
    let birthCountry: String
    let height: String
    let weight: Int
    
    let currentTeam: Int
    
    let primaryPosition: String
    
    let batSide: String
    
    let pitchHand: String
    
    let boxscoreName: String
    let initLastName: String
}
