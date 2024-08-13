//  PlayerListView.swift
//  betMLB
//  Created by Andrew Xin on 8/4/24.

import SwiftUI
import SDWebImageSwiftUI

struct PlayerListView: View {
    @State private var viewModel = PlayerListViewVM()
    @FocusState private var isSearching: Bool
    @Environment(\.colorScheme) private var scheme
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 2) {
                    ForEach(viewModel.filteredPlayers, id: \.id) { player in
                        NavigationLink(destination: NavigationLazyView(DetailPlayerView(players: player))) {
                            PlayerCardView(player: player)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    ExpandableNavigationBar()
                }
                .animation(.snappy(duration: 0, extraBounce: 0), value: isSearching)
            }
            .scrollTargetBehavior(CustomScrollTargetBehavior())
            .background(.gray.opacity(0.15))
            .contentMargins(.top, 190, for: .scrollIndicators)
            .task {
                await viewModel.loadData()
            }
            .onDisappear {
                viewModel.cancelLoadingTasks()
            }
        }
    }
    
    // Player Card View
    @ViewBuilder func PlayerCardView(player: Player) -> some View {
        ZStack {
            if let colors = teamColors[mapTeamIdToAbbreviation(fromId: player.currentTeam.id)] {
                LinearGradient(
                    gradient: Gradient(colors: [colors.first!]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.6)
            } else {
                Color.white // Fallback color
            }
            HStack {
                VStack(alignment: .trailing) {
                    // Team Logo
                    Image.teamLogoImage(for: player.currentTeam.id)
                        .frame(width: 40, height: 40)
                        .padding(8)
                    Spacer()
                    // Position Bubble
                    if let teamColor = teamColors[mapTeamIdToAbbreviation(fromId: player.currentTeam.id)] {
                        Text(player.primaryPosition.abbreviation)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(width: 25, height: 15)
                            .padding(8)
                            .background(teamColor[1])
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(teamColor[0], lineWidth: 2))
                            .offset(x: -7, y: -7)
                    } else {
                        Text(player.primaryPosition.abbreviation)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(width: 25, height: 15)
                            .padding(8)
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.red, lineWidth: 2))
                            .offset(x: -7, y: -7)
                    }
                }
                .padding(.trailing, 15)
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
                        if let num = player.primaryNumber {
                            Text("#\(num)")
                                .font(.subheadline)
                        } else {
                            Text("N/A")
                                .font(.subheadline)
                        }
                    }
                    Text("DOB: \(player.birthDateFormatted ?? player.birthDate) (\(player.currentAge))")
                        .font(.subheadline)
                    Text("Bats/Throws: \(player.batSide.code) / \(player.pitchHand.code)")
                        .font(.subheadline)
                }
                Spacer()
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    // Expandable Navigation Bar
    @ViewBuilder func ExpandableNavigationBar(_ title: String = "Players") -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let scrollviewHeight = proxy.bounds(of: .scrollView(axis: .vertical))?.height ?? 0
            let scaleProgress = minY > 0 ? 1 + (max(min(minY / scrollviewHeight, 1), 0) * 0.5) : 1
            let progress = isSearching ? 1 : max(min(-minY/70, 1), 0) // Lower the value, faster the scrolling
            
            VStack(spacing: 10) {
                // Title
                Text(title)
                    .font(.largeTitle.bold())
                    .scaleEffect(scaleProgress, anchor: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                    TextField("Search Players", text: $viewModel.searchText)
                        .focused($isSearching)
                    if isSearching {
                        Button(action: {
                            isSearching = false
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        })
                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    }
                }
                .foregroundStyle(Color.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 15 - (progress * 15))
                .frame(height: 45)
                .clipShape(.capsule)
                .background {
                    RoundedRectangle(cornerRadius: 25 - (progress * 25))
                        .fill(.background)
                        .padding(.top, -progress * 190)
                        .shadow(color: .gray.opacity(0.25), radius: 5, x: 0, y: 5)
                        .padding(.bottom, -progress * 65)
                        .padding(.horizontal, -progress * 15)
                }
                
                // Segmented Picker
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(PlayerTab.allCases, id: \.rawValue) { tab in
                            Button(action: {
                                withAnimation(.snappy) {
                                    viewModel.activeTab = tab
                                }
                            }) {
                                Text(tab.rawValue)
                                    .font(.callout)
                                    .foregroundStyle(viewModel.activeTab == tab ? (scheme == .dark ? .black : .white) : Color.primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)
                                    .background {
                                        if viewModel.activeTab == tab {
                                            Capsule()
                                                .fill(Color.primary)
                                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                        } else {
                                            Capsule()
                                                .fill(.background)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top, 25)
            .safeAreaPadding(.horizontal, 15)
            .offset(y: minY < 0 || isSearching ? -minY : 0)
            .offset(y: -progress * 65)
        }
        .frame(height: 190)
        .padding(.bottom, 10)
        .padding(.bottom, isSearching ? -65 : 0)
    }
}

struct CustomScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < 70 {
            if target.rect.minY < 35 {
                target.rect.origin = .zero
            } else {
                target.rect.origin = .init(x: 0, y: 70)
            }
        }
    }
}

#Preview {
    PlayerListView()
}
