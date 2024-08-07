//  TeamListView.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import SwiftUI

struct TeamListView: View {
    @State private var viewModel = TeamListViewVM()
    
    var body: some View {
        List{
            ForEach(viewModel.teams, id: \.id) { team in
                Text("team: \(team.name)")
                if let hitting = team.hittingStats, let pitching = team.pitchingStats, let fielding = team.fieldingStats {
                    Text("AVG: \(hitting.AVG)")
                    Text("ERA: \(pitching.ERA)")
                    Text("FP: \(fielding.FP)")
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
    
}

#Preview {
    TeamListView()
}
