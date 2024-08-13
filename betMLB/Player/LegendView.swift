//  LegendView.swift
//  betMLB
//  Created by Andrew Xin on 8/12/24.

import SwiftUI

struct LegendView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Excellent")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Great")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.cyan)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Better")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Average")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Worse")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Poor")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
                VStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    Text("Awful")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 45)
                Spacer()
            }
        }
    }
}

#Preview {
    LegendView()
}
