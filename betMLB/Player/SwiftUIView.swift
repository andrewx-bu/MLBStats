//
//  SwiftUIView.swift
//  betMLB
//
//  Created by Andrew Xin on 8/12/24.
//

import SwiftUI

struct SwiftUIView: View {
    let statistics = [
        ("Batting Average", ".300"),
        ("Home Runs", "20"),
        ("Runs Batted In", "75"),
        ("Strikeouts", "85"),
        ("ERA", "3.20"),
        ("Wins", "15"),
        ("Saves", "25")
        ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 2) {
                ForEach(statistics, id: \.0) { stat in
                    HStack {
                        Text(stat.0) // Statistic name
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Grade")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(stat.1) // Statistic value
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 25)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
            .preferredColorScheme(.dark)
            .padding()
        }
    }
}

#Preview {
    SwiftUIView()
}
