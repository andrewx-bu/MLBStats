//  TestView.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import SwiftUI

struct TestView: View {
    @State private var viewModel = TestViewVM()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Players")
                .font(.largeTitle)
                .padding()
            
            List(viewModel.players, id: \.id) { player in
                VStack(alignment: .leading) {
                    HStack {
                        if let image = viewModel.playerImages[player.id] {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                        } else {
                            Text("No Image")
                                .frame(width: 50, height: 50)
                        }
                        Text(player.fullName)
                            .font(.headline)
                        Spacer()
                        Text("\(player.id)")
                            .font(.caption)
                    }
                    if let AVG = player.hittingStats?.AVG {
                        Text("AVG: \(AVG)")
                    }
                    if let BABIP = player.pitchingStats?.BABIP {
                        Text("BABIP: \(BABIP)")
                    }
                    if let DEF = player.fieldingStats?.DEF {
                        Text("DEF: \(DEF)")
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    TestView()
}
