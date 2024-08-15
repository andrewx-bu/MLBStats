//  CalendarView.swift
//  betMLB
//  Created by Andrew Xin on 8/3/24.

import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewVM()
    var safeArea: EdgeInsets
    
    var body: some View {
        let maxHeight = calendarHeight - (calendarTitleViewHeight + weekLabelHeight + safeArea.top + topPadding + bottomPadding)
        ScrollView(.vertical) {
            VStack(spacing: 0) { 
                CalView()
                VStack(spacing: 15) {
                    ForEach(viewModel.schedule, id: \.date) { scheduleDate in
                        ForEach(scheduleDate.games, id: \.gamePk) { game in
                            GameCardView(game: game)
                        }
                    }
                }
                .padding(15)
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(CustomScrollBehavior(maxHeight: maxHeight))
        .task {
            await viewModel.loadGames()
        }
    }
    
    // ScheduleView
    @ViewBuilder func GameCardView(game: ScheduleDate.Game) -> some View {
        if let awayColors = teamColors[mapTeamIdToAbbreviation(fromId: game.teams.away.team.id)], let homeColors = teamColors[mapTeamIdToAbbreviation(fromId: game.teams.home.team.id)] {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                        gradient: Gradient(colors: [awayColors.first!, homeColors.first!]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 75)
                    .overlay(alignment: .leading) {
                        HStack(spacing: 12) {
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(awayColors[1].opacity(0.7))
                                .overlay(
                                    Image.teamLogoImage(for: game.teams.away.team.id)
                                        .frame(width: 25, height: 25)
                                )
                                .offset(x: -5, y: -10)
                            Spacer()
                            Circle()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(homeColors[1].opacity(0.7))
                                .overlay(
                                    Image.teamLogoImage(for: game.teams.home.team.id)
                                        .frame(width: 25, height: 25)
                                )
                                .offset(x: 5, y: 10)
                        }
                        .foregroundStyle(.white.opacity(0.25))
                        .padding(15)
                    }
                
                Path { path in
                    path.move(to: CGPoint(x: 5, y: 70))
                    path.addLine(to: CGPoint(x: 175, y: 40))
                }
                .stroke(style: StrokeStyle(lineWidth: 2))
                .foregroundColor(.white.opacity(0.5))
                Path { path in
                    path.move(to: CGPoint(x: 189, y: 37))
                    path.addLine(to: CGPoint(x: 360, y: 5))
                }
                .stroke(style: StrokeStyle(lineWidth: 2))
                .foregroundColor(.white.opacity(0.5))
                Text("@")
                VStack {
                    Text("\(mapTeamIdToAbbreviation(fromId: game.teams.away.team.id))")
                        .font(.headline)
                    Text("\(game.teams.away.leagueRecord.wins)-\(game.teams.away.leagueRecord.losses)")
                        .font(.caption2)
                }
                .offset(x: -75, y: -10)
                VStack {
                    Text("\(mapTeamIdToAbbreviation(fromId: game.teams.home.team.id))")
                        .font(.headline)
                    Text("\(game.teams.home.leagueRecord.wins)-\(game.teams.home.leagueRecord.losses)")
                        .font(.caption2)
                }
                .offset(x: 75, y: 10)
                Text("\(game.teams.away.score ?? 0) - \(game.teams.home.score ?? 0)")
                    .font(.headline)
                    .offset(y: -25)
                Text("\(game.status.detailedState)")
                    .font(.caption)
                    .offset(y: 25)
            }
        }
    }
    
    // Calendar View
    @ViewBuilder func CalView() -> some View {
        GeometryReader {
            let size = $0.size
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
            // converting scroll into progress
            let maxHeight = size.height - (calendarTitleViewHeight + weekLabelHeight + safeArea.top + topPadding + bottomPadding)
            let progress = max(min((-minY / maxHeight), 1), 0)
            VStack(alignment: .leading, spacing: 0) {
                Text(currentMonth)
                    .font(.system(size: 35 - (10 * progress)))
                    .offset(y: -50 * progress)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .overlay(alignment: .topLeading) {
                        GeometryReader {
                            let size = $0.size
                            Text(year)
                                .font(.system(size: 25 - (10 * progress)))
                                .offset(x: (size.width + 5) * progress, y: progress * 3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: 15) {
                            Button("", systemImage: "chevron.left") {
                                monthUpdate(false)
                            }
                            .contentShape(.rect)
                            Button("", systemImage: "chevron.right") {
                                monthUpdate(true)
                            }
                            .contentShape(.rect)
                        }
                        .font(.title3)
                        .foregroundStyle(.primary)
                        .offset(x: 150 * progress)
                    }
                    .frame(height: calendarTitleViewHeight)
                VStack(spacing: 0) {
                    // Day Labels
                    HStack(spacing: 0) {
                        ForEach(Calendar.current.weekdaySymbols, id: \.self) { symbol in
                            Text(symbol.prefix(3))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: weekLabelHeight, alignment: .bottom)
                    
                    // Calendar Grid View
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0) {
                        ForEach(selectedMonthDates) { day in
                            Text(day.shortSymbol)
                                .foregroundStyle(day.ignored ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(alignment: .bottom) {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 5, height: 5)
                                        .opacity(Calendar.current.isDate(day.date, inSameDayAs: viewModel.selectedDate) ? 1 : 0)
                                        .offset(y: progress * -2)
                                }
                                .contentShape(.rect)
                                .onTapGesture {
                                    viewModel.selectedDate = day.date
                                }
                        }
                    }
                    .frame(height: calendarGridHeight - ((calendarGridHeight - 50) * progress), alignment: .top)
                    .offset(y: (monthProgress * -50) * progress)
                    .contentShape(.rect)
                    .clipped()
                }
                .offset(y: progress * -50)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.top, safeArea.top)
            .padding(.bottom, bottomPadding)
            .frame(maxHeight: .infinity)
            .frame(height: size.height - (maxHeight * progress), alignment: .top)
            .background(.indigo.gradient)
            // sticking it to top
            .clipped()
            .contentShape(.rect)
            .offset(y: -minY)
        }
        .frame(height: calendarHeight)
        .zIndex(1000)
    }
    
    // Date Formatter
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: viewModel.selectedMonth)
    }
    
    // Month Increment/Decrement
    func monthUpdate(_ increment: Bool = true) {
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: viewModel.selectedMonth) else { return }
        guard let date = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: viewModel.selectedDate) else { return }
        viewModel.selectedMonth = month
        viewModel.selectedDate = date
    }
    
    var selectedMonthDates: [Day] {
        return extractDates(viewModel.selectedMonth)
    }
    
    // Current Month String
    var currentMonth: String {
        return format("MMMM")
    }
    
    // Selected Year
    var year: String {
        return format("YYYY")
    }
    
    var monthProgress: CGFloat {
        let calendar = Calendar.current
        if let index = selectedMonthDates.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: viewModel.selectedDate )}) {
            return CGFloat(index / 7).rounded()
        }
        return 1.0
    }
    
    // View Heights & Paddings
    var calendarHeight: CGFloat {
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + safeArea.top + topPadding + bottomPadding
    }
    
    var calendarTitleViewHeight: CGFloat {
        return 75.0
    }
    
    var horizontalPadding: CGFloat {
        return 15.0
    }
    
    var weekLabelHeight: CGFloat {
        return 30.0
    }
    
    var calendarGridHeight: CGFloat {
        // Each row is height 50, 7 columns
        return CGFloat(selectedMonthDates.count / 7) * 50
    }
    
    var topPadding: CGFloat {
        return 15.0
    }
    
    var bottomPadding: CGFloat {
        return 15.0
    }
}

// Custom Scroll Behavior
struct CustomScrollBehavior: ScrollTargetBehavior {
    var maxHeight: CGFloat
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < maxHeight {
            target.rect = .zero
        }
    }
}

#Preview {
    GeometryReader {
        let safeArea = $0.safeAreaInsets
        CalendarView(safeArea: safeArea)
            .ignoresSafeArea(.container, edges: .top)
            .preferredColorScheme(.dark)
    }
}
