//  ContentView.swift
//  betMLB
//  Created by Andrew Xin on 8/2/24.

import SwiftUI

struct ContentView: View {
    @State private var activeTab: Tab = .calendar
    // All Tabs
    @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab ->
        AnimatedTab? in
        return .init(tab: tab)
    }
    
    init() {
        // Something is wrong with the transparency of the tab bar so its just black for now
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                // CalendarView
                GeometryReader {
                    let safeArea = $0.safeAreaInsets
                    CalendarView(safeArea: safeArea)
                        .ignoresSafeArea(.container, edges: .top)
                }
                .setUpTab(.calendar)
                // PlayerView
                PlayerListView()
                    .setUpTab(.players)
                // TeamView
                TeamListView()
                    .setUpTab(.teams)
                // BookmarkView
                NavigationStack {
                    VStack {
                        
                    }
                    .navigationTitle(Tab.bookmarks.title)
                }
                .setUpTab(.bookmarks)
            }
            CustomTabBar()
        }
        .preferredColorScheme(.dark)
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
