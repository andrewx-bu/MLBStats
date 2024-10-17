# Table of Contents
- [MLBStats](#mlbstats)
- [Description and Usage](#description-and-usage)
  - [CalendarView](#calendarview)
  - [Detail GameView](#detail-gameview)
  - [PlayerListView](#playerlistview)
  - [DetailPlayerView](#detailplayerview)
- [Architecture and Structure](#architecture-and-structure)
- [API and Dependencies](#api-and-dependencies)
- [Issues and Unimplemented Stuff](#issues-and-unimplemented-stuff)
# MLBStats
A project that tracks baseball games over the MLB season. Key features include a calendar view with scheduled + active games, an in detail game view, player list, and player stats view.
## Description and Usage
Fun little side project for myself to follow the 2024 MLB season. </br>
Thre are two main views, each with a subview:
- CalendarView
    - DetailGameView
- PlayerListView
    - DetailPlayerView </br>
### CalendarView
<em>Stationary Calendar vs. Compressed Calendar</em> </br>
<img src="Screenshots/1.1-Calendar.png" alt="Stationary Calendar View" width="250">
<img src="Screenshots/1.2-CalendarCompressed.png" alt="Compressed Calendar View" width="250"> </br>
Description </br>
______________________________
<em>Calendar showing scheduled games vs. showing only active games</em> </br>
<img src="Screenshots/1.3-CalendarScheduled.png" alt="Scheduled Games Calendar" width="250">
<img src="Screenshots/1.4-CalendarInGame.png" alt="Active Games Only Calendar" width="250"> </br>
Description

### Detail GameView
<em>Active game being tracked with linescore</em> </br>
<img src="Screenshots/2.0-DetailGameActive.png" alt="Active Detail Game View" width="250"> </br>
Description </br>
______________________________
<em>Linescore + Probable Pitchers, Batting Leaders + Team Stats</em> </br>
<img src="Screenshots/2.1-DetailGame.png" alt="Linescore + Probable Pitchers" width="250">
<img src="Screenshots/2.2-DetailGame2.png" alt="Batting Leaders + Team Stats" width="250"> </br>
Description </br>
______________________________
<em>Predictions (RA/5)</em> </br>
<img src="Screenshots/2.3-DetailPrediction.png" alt="Prediction (RA/5)" width="250">
<img src="Screenshots/2.4-DetailPrediction2.png" alt="Prediction Pt. 2 (RA/5)" width="250"> </br>
Description

### PlayerListView
<em>Player List</em> </br>
<img src="Screenshots/3.1-PlayerList.png" alt="Player List" width="250"> </br>
Description </br>
______________________________
<em>Player Search + Position Tab Bar</em> </br>
<img src="Screenshots/3.2-PlayerSearch.png" alt="Player Search" width="250">
<img src="Screenshots/3.3-PlayerTabBar.png" alt="Position Tab Bar" width="250"> </br>
Description

### DetailPlayerView
<em>Detail Player + Detail Player Stats</em> </br>
<img src="Screenshots/4.1-DetailPlayer.png" alt="Detail Player" width="250">
<img src="Screenshots/4.2-DetailPlayerStats.png" alt="Detail Player Stats" width="250"> </br>
Description </br>
______________________________
<em>Detail Pitcher + Catcher</em> </br>
<img src="Screenshots/4.3-DetailPitcher.png" alt="Detail Pitcher" width="250">
<img src="Screenshots/4.4-DetailCatcher.png" alt="Detail Catcher" width="250"> </br>
Description

## API and Dependencies
- All statistics and heashot images are scraped from FanGraphs MLB leaderboards (https://www.fangraphs.com/leaders/major-league).
- Schedule, Lineups, and Player Bios are pulled from MLB-StatsAPI (https://github.com/toddrob99/MLB-StatsAPI).
- Uses `SDSDWebImageSVGCoder` to render team logo SVG images (https://github.com/SDWebImage/SDWebImageSVGCoder)
## Architecture and Structure
- MLBStats is implemented *mostly* using the **MVVM** architecture pattern
    - Subviews (inside Navigation Links) lack any architecture, and they are extremely unorganized
- The `Fetcher.swift` file in the `Models` directory is responsible for fetching and decoding all data  
    - Uses Swift `async` to asynchronously fetch data from Fangraphs API and MLB-StatsAPI endpoints
    - Data fetched from API endpoints are all JSON. `Fetcher` is responsible for decoding all data.
    - Key functions include `fetchPlayers()`, `fetchTeams()`, `fetchPlayerImage(for:)`, and more
    - Example:
        - The function `fetchLineupData` is called to find batting lineups, probable pitchers, and bullpens for a `gamePk` id specifier
            ```swift
            func fetchLineups(gamePk: Int) async throws -> LineupData? {
                let urlString = "https://statsapi.mlb.com/api/v1.1/game/\(gamePk)/feed/live"
                guard let url = URL(string: urlString) else {
                    print("fetchLineups: Invalid game data URL")
                    throw URLError(.badURL)
                }
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let response = try JSONDecoder().decode(LiveDataResponse.self, from: data)
                    let lineupData = LineupData(
                        awayBatters: response.liveData.boxscore.teams.away.battingOrder,
                        awayStartingPitchers: response.liveData.boxscore.teams.away.pitchers,
                        awayBullpen: response.liveData.boxscore.teams.away.bullpen,
                        homeBatters: response.liveData.boxscore.teams.home.battingOrder,
                        homeStartingPitchers: response.liveData.boxscore.teams.home.pitchers,
                        homeBullpen: response.liveData.boxscore.teams.home.bullpen
                    )
                    return lineupData
                } catch {
                    print("fetchLineups: \(error)")
                    throw error
                }
                return nil
            }
            ```
- All views utilize Swift's new concurrency features (`async`, `await`, `.task`) to effeciently load data
    - Example:
        - Upon loading the `CalendarView` view, a task is created calling the view model's asynchronous `loadGames()` function:
            ```swift
            .task { 
                await viewModel.loadGames() 
            }
            ```
        - The viemodel `CalendarViewVM` creates an instance of `Fetcher` and calls `fetchSchedule(selectedDate)` to populate the `schedule` variable:
            ```swift
            func loadGames() async {
                do {
                    self.schedule = try await fetcher.fetchSchedule(date: selectedDate)
                } catch {
                    print("loadGames: Error fetching data")
                }
            }
            ```
    - For heavy-memory usage screens, tasks are cancelled upon views disappearing
        ```swift
            // PlayerListView
            .onDisappear {
                viewModel.cancelLoadingTasks()
            }
            // PlayerListViewVM
            func cancelLoadingTasks() {
                print("Cancelling player loadData task")
                loadDataTask?.cancel()
            }
        ```
- The `Extensions.swift` file contains extensions to improve readability
    - Example:
        - An extension to format string date values
            ```swift
            extension String {
                // Formats a date like: "2024-07-08T16:35:00Z to 4:35 PM"
                func formattedGameTime() -> String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    if let date = dateFormatter.date(from: self) {
                        dateFormatter.dateFormat = "h:mm a"
                        return dateFormatter.string(from: date)
                    }
                    return self
                }
            }
            ```
- The `TeamIDMapping.swift` file maps MLB team IDs and abbreviations between the two APIs. 
    - MLB-StatsAPI and Fangraphs API use different IDs for player and teams
    - The file also contains a hardcoded dictionary for team colors:
        - Example:
            ```swift 
            "KC": [Color(hex: "#004687"), Color(hex: "#BD9B60")], // Kansas City Royals 
            ```
- Stats are decoded into three separate categories: hitting, pitching, and fielding (which includes catching), represented in their respective files: `HittingStats.swift`, `PitchingStats.swift`, and `FieldingStats.swift`. These conform to a protocol called `IdentifiableStat`
    - `IdentifableStat` is used to generically categorize all these stat items, and to match players to their stat objects
        ```swift
        protocol IdentifiableStat: Identifiable {
            var id: Int { get }
            var teamid: Int { get }
        }
        ```
- These three identifiable stat objects are then all added to their respective `Player` object.
    - `Player`'s biography details still come from MLB-StatsAPI.
        - `Player` class:
            ```swift
            struct Player: Identifiable, Decodable {
                let id: Int                                 // 671096
                var headshotId: Int?                        // 25764 (Fangraphs)
                let fullName: String                        // Andrew Abbott
                let birthCity: String?                      // Lynchburg
                let currentTeam: Team
                struct Team: Identifiable, Decodable {
                    let id: Int                             // 113
                    let link: String                        // /api/v1/teams/113
                }
                // more bio details...

                // optional statistic objects from Fangraphs
                var hittingStats: HittingStats?
                var pitchingStats: PitchingStats?
                var fieldingStats: FieldingStats?
            }
            ```
- Matching `Player` to their `IdentifiableStat` objectsin the `PlayerViewVM` view model </br>
    1. Player data and stats are fetched asynchronously:
        ```swift
        async let fetchedPlayers = fetcher.fetchPlayers()
        async let fetchedHittingStats: [HittingStats] = fetcher.fetchStats(statType: .hitting)
        async let fetchedPitchingStats: [PitchingStats] = fetcher.fetchStats(statType: .pitching)
        async let fetchedFieldingStats: [FieldingStats] = fetcher.fetchStats(statType: .fielding)
        
        let players = try await fetchedPlayers
        let hittingStats = try await fetchedHittingStats
        let pitchingStats = try await fetchedPitchingStats
        let fieldingStats = try await fetchedFieldingStats
        
        self.players = players
        let hittingStatsDictionary = dictionaryMaker.makePlayerHittingDictionary(hittingStats: hittingStats)
        let pitchingStatsDictionary = dictionaryMaker.makePlayerPitchingDictionary(pitchingStats: pitchingStats)
        let fieldingStatsDictionary = dictionaryMaker.makePlayerFieldingDictionary(fieldingStats: fieldingStats)
        ```
    2. Stats are organized into dictionaries using the `DictionaryMaker` class functions. Player `id` is used as key (`useTeamId` is for fetching team statistics, but the logic for matching teams to their stats is the same)
        ```swift
        func makeDictionary<T: IdentifiableStat>(stats: [T], useTeamId: Bool = false) -> [Int: T] {
            var dictionary = [Int: T]()
            for stat in stats {
                let key = useTeamId ? stat.teamid : stat.id
                dictionary[key] = stat
            }
            return dictionary
        }
        ```
    3. The player object is updated with the matched stats if applicable:
        ```swift
        private func updatePlayersWithStats(hittingStatsDictionary: HittingStatsDictionary, pitchingStatsDictionary: PitchingStatsDictionary, fieldingStatsDictionary: FieldingStatsDictionary) {
            players = players.map { player in
                var updatedPlayer = player
                
                // Match player with his stats
                if let hitting = hittingStatsDictionary[player.id] {
                    updatedPlayer.hittingStats = hitting
                    // Extract fangraphs id for getting headshot later
                    updatedPlayer.headshotId = hitting.playerid
                }
                
                if let pitching = pitchingStatsDictionary[player.id] {
                    updatedPlayer.pitchingStats = pitching
                    updatedPlayer.headshotId = pitching.playerid
                }
                
                if let fielding = fieldingStatsDictionary[player.id] {
                    updatedPlayer.fieldingStats = fielding
                    updatedPlayer.headshotId = fielding.playerid
                }
                
                return updatedPlayer
            }
        }
        ```
## Issues and Unimplemented Stuff
<em>Memory Issue</em> </br>
<img src="Screenshots/9-MemoryIssue.png" alt="Detail Catcher" width="250"> </br>
Description </br>
______________________________
<em>Black Bar</em> </br>
<img src="Screenshots/4.2-DetailPlayerStats.png" alt="Detail Player Stats" width="250"> </br>
Description </br>
______________________________
<em>Unknown Pitcher, Unknown Stats</em> </br>
<img src="Screenshots/2.0-DetailGameActive.png" alt="Active Detail Game View" width="250">
<img src="Screenshots/2.3-DetailPrediction.png" alt="Prediction (RA/5)" width="250"> </br>
Description </br>