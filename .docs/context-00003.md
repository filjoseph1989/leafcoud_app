[Main](/context/context-00000.md) | [Previous](/context/context-00002.md)

## Changes Made to HistoryScreen and DashboardScreen

### HistoryScreen (`lib/history_screen.dart`)
- Added sample historical data directly into the `HistoryScreen` widget. This data mimics the structure of the `history` endpoint response, including `timestamp`, `n_ppm`, `p_ppm`, `k_ppm`, `ec`, `ph`, and `temp_c`.
- Implemented a `ListView.builder` to display each historical data entry in a `Card` widget. Each card shows the timestamp and all sensor/prediction values in a readable format.
- Removed the `const` keyword from the `HistoryScreen` constructor as it now contains mutable data (`historyData`).

### DashboardScreen (`lib/dashboard_screen.dart`)
- Modified the `MaterialPageRoute` for navigating to `HistoryScreen` by removing the `const` keyword from `HistoryScreen()` to align with the changes in `HistoryScreen`'s constructor.

[Next](/context/context-00004.md)