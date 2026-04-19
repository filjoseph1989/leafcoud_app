# Implementation Plan: UI Redesign (Clean & Modern)

## Phase 1: Setup Centralized ThemeData
- [x] Task: Define new Leafcloud colors, typography, and shape themes in a dedicated theme file or within `main.dart`. 71a66ba
    - [x] Update primary/secondary colors to use existing brand colors.
    - [x] Define global `CardTheme` with soft drop shadows and rounded corners.
    - [x] Define global `ElevatedButtonTheme` with rounded corners.
    - [x] Define global `InputDecorationTheme` for TextFields.
    - [x] Define global `TextTheme` for modern, clean typography.
- [x] Task: Apply new `ThemeData` to the `MaterialApp` in `main.dart`. 71a66ba
- [x] Task: Update existing or add basic widget tests to verify `MaterialApp` correctly provides the new theme. 71a66ba
- [x] Task: Conductor - User Manual Verification 'Setup Centralized ThemeData' (Protocol in workflow.md) 71a66ba

## Phase 2: Refactor Screens to use global theme
- [x] Task: Update Landing and Login Screens. 708fa88
    - [x] Remove hardcoded styles and replace with `Theme.of(context)` where necessary.
    - [x] Verify layout constraints with new styling.
    - [x] Update widget tests for Landing and Login screens to ensure no regressions.
- [x] Task: Update Dashboard and Connection Setup Screens. 708fa88
    - [x] Remove hardcoded styles and replace with `Theme.of(context)`.
    - [x] Ensure cards and specific data widgets adopt the new `CardTheme`.
    - [x] Update widget tests for Dashboard and Connection Setup screens.
- [x] Task: Update Data Gathering, Experiment Management, and History/Gallery Screens. 708fa88
    - [x] Remove hardcoded styles.
    - [x] Update specific components like Image grids to match the soft-shadow/rounded-corner look.
    - [x] Update widget tests for these screens.
- [x] Task: Conductor - User Manual Verification 'Refactor Screens to use global theme' (Protocol in workflow.md) 708fa88

## Phase 3: Final Polish and Review
- [x] Task: Conduct visual review across all screens to ensure consistency. 708fa88
    - [x] Fix any visual anomalies or overflow errors caused by new paddings/margins/shapes.
- [x] Task: Update any remaining snapshot tests or specific UI tests. 708fa88
- [x] Task: Conductor - User Manual Verification 'Final Polish and Review' (Protocol in workflow.md) 708fa88
## Phase: Review Fixes
- [x] Task: Apply review suggestions f38d4c4
