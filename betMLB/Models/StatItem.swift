//  StatItem.swift
//  betMLB
//  Created by Andrew Xin on 8/12/24.

import SwiftUI

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack() {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 25)
    }
}

struct PlusStatItem: View {
    let title: String
    let value: Double?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let value = value {
                Text(String(format: "%.2f", value))
                    .font(.body)
                    .foregroundColor(color(for: value).opacity(0.85))
            } else {
                Text("N/A")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 25)
    }
    
    private func color(for value: Double) -> Color {
        let average = 100.0
        let deviation = value - average
        
        switch deviation {
        case _ where deviation >= 20:
            return .blue // Considerably better
        case _ where deviation >= 10:
            return .cyan // Better
        case _ where deviation <= -20:
            return .red // Considerably worse
        case _ where deviation <= -10:
            return .yellow // Worse
        default:
            return .purple // Average
        }
    }
}

#Preview {
    VStack {
        StatItem(title: "AVG", value: ".8329342")
        PlusStatItem(title: "AVG+", value: 112.2)
        PlusStatItem(title: "AVG+", value: 15.34332)
        PlusStatItem(title: "AVG+", value: 99)
        PlusStatItem(title: "AVG+", value: 130.34)
        PlusStatItem(title: "AVG+", value: 85)
    }
    .preferredColorScheme(.dark)
}
