# MLBStats
Refactored version of old MLBStats. New features include player images + stats page, in detail schedule screen (probable pitchers + batting leaders), and tab bar. 
Team screen and bookmark screen are planned to be added, along with reorganization of complex views.
Tried to keep things MVVM but spiraled terribly out of control at the end with optionals and detail screens from NavLinks.
Reorganized player models using dictionaries for matching. Attempted to centralized fetch calls in a Fetcher class. Handled extensive errors from decoding.
Uses UI elements from Kavsoft (https://www.youtube.com/watch?v=FvgmcwjDFvQ, https://www.youtube.com/watch?v=KiMVgmqtOqY).
Stats are scraped from FanGraphs MLB leaderboards (https://www.fangraphs.com/leaders/major-league).
Schedule and Lineups are pulled from MLB-StatsAPI (https://github.com/toddrob99/MLB-StatsAPI).
