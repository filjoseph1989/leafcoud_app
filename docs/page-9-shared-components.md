[Prev](./page-8-sensor-calibration.md) | [Next](./page-10-user-registration.md)

# Shared UI Components

This document describes reusable widgets used across multiple screens in the LeafCloud app.

## 1. `AppFooter` (`lib/ui/widgets/app_footer.dart`)

A consistent branding footer rendered at the bottom of every scrollable screen.

### Appearance
```
─────────────────────────────────────────
  🌿 LeafCloud  ·  Smart Hydroponics Monitoring
        © 2026 LeafCloud
```

### Usage
```dart
import 'package:leaf_cloud/ui/widgets/app_footer.dart';

// Inside a Column or ListView:
const AppFooter()
```

### Screens that include it
| Screen | How it's added |
|---|---|
| Dashboard | Last child of the main `Column` inside `SingleChildScrollView` |
| Alerts | Extra item at end of `ListView.builder` (`itemCount + 1`) |
| Reading History — Photos tab | Extra item at end of `ListView.builder` |
| Reading History — Trends tab | Last child of `ListView` |
| Reservoir Settings | Extra item at end of `ListView.builder` |
| Sensor Calibration | Extra item at end of `ListView.builder` |

### Implementation notes
- Uses `const` constructor — zero rebuild cost.
- The `ListView.builder` pattern adds `itemCount: items.length + 1` and checks `if (index == items.length) return const AppFooter()` to insert the footer without modifying the data list.
