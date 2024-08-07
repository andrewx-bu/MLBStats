//  ContentView.swift
//  betMLB
//  Created by Andrew Xin on 8/2/24.

import SwiftUI

struct ContentView: View {
    @State private var activeTab: Tab = .home
    // All Tabs
    @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab ->
        AnimatedTab? in
        return .init(tab: tab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                // HomeView
                NavigationStack {
                    VStack {
                        PlayerListView()
                    }
                }
                .setUpTab(.home)
                // CalendarView
                GeometryReader {
                    let safeArea = $0.safeAreaInsets
                    CalendarView(safeArea: safeArea)
                        .ignoresSafeArea(.container, edges: .top)
                }
                .setUpTab(.calendar)
                // BookmarkView
                NavigationStack {
                    VStack {
                        TeamListView()
                    }
                    .navigationTitle(Tab.bookmarks.title)
                }
                .setUpTab(.bookmarks)
                // ProfileView
                NavigationStack {
                    VStack {
                        
                    }
                    .navigationTitle(Tab.profile.title)
                }
                .setUpTab(.profile)
            }
            CustomTabBar()
        }
    }
    
    // Tab Bar
    @ViewBuilder func CustomTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach($allTabs) { $animatedTab in
                let tab = animatedTab.tab
                
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .font(.title2)
                        .symbolEffect(.bounce.down.byLayer, value: animatedTab.isAnimating)
                    
                    Text(tab.title)
                        .font(.caption2)
                        .textScale(.secondary)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(activeTab == tab ? Color.primary : Color.gray.opacity(0.8))
                .padding(.top, 15)
                .padding(.bottom, -15)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
                        activeTab = tab
                        animatedTab.isAnimating = true
                    }, completion: {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            animatedTab.isAnimating = nil
                        }
                    })
                }
            }
        }
        .background(.bar)
    }
}

#Preview {
    ContentView()
}
