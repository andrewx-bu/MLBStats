//  TeamListView.swift
//  betMLB
//  Created by Andrew Xin on 8/7/24.

import SwiftUI

struct TeamListView: View {
    @State private var viewModel = TeamListViewVM()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.teams, id: \.id) { team in
                    Text("team: \(team.name)")
                    if let hittingStats = team.hittingStats {
                        Text("H")
                    }
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
