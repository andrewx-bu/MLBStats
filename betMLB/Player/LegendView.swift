//  LegendView.swift
//  betMLB
//  Created by Andrew Xin on 8/12/24.

import SwiftUI

struct LegendView: View {
    private let colors: [Color] = [
        .green,   // Great
        .blue,    // Excellent
        .cyan,    // Above Average
        .purple,  // Average
        .yellow,  // Below Average
        .orange,  // Poor
        .red      // Awful
    ]
    
    var body: some View {
        HStack {
            Text("Excellent")
                .font(.caption)
                .foregroundColor(.primary)
            
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 15)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
            )
            
            Text("Awful")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }
    
}

#Preview {
    LegendView()
}
