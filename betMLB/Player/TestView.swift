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
                        Text(player.fullName)
                            .font(.headline)
                        Spacer()
                        Text("\(player.id)")
                            .font(.caption)
                    }
                    Text("AVG: \(player.hittingStats?.AVG)")
                    Text("ERA: \(player.pitchingStats?.ERA)")
                    Text("FP: \(player.fieldingStats?.FP)")
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
