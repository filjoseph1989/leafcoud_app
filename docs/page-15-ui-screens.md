[Prev](./page-14-account-lifecycle-client.md) | [Next](./page-16-use-case-farm-operator.md)

# UI Screens & Components

## Authentication

| Screen | File | Purpose |
|--------|------|---------|
| **LoginPage** | `lib/ui/login_page.dart` | Email/password login with server connection status |
| **RegisterPage** | `lib/ui/register_page.dart` | New user registration, accessed from the nav drawer |

---

## Core Navigation

| Screen | File | Purpose |
|--------|------|---------|
| **HomePage** | `lib/ui/home_page.dart` | Shell with AppBar (featuring a notification bell icon and refresh action) and drawer navigation; hosts the dashboard by default |

---

## Monitoring & Alerts

| Screen | File | Purpose |
|--------|------|---------|
| **DashboardScreen** | `lib/ui/dashboard_screen.dart` | Real-time view of reservoir health — sensor readings (pH, EC, temp), AI advisory, nutrient estimates (N/P/K in PPM), and anomaly warnings |
| **AlertsScreen** | `lib/ui/alerts_screen.dart` | Lists nutrient alerts per reservoir with severity (Critical/Warning/Normal) and required top-up amounts |

---

## History & Analytics

| Screen | File | Purpose |
|--------|------|---------|
| **HistoryScreen** | `lib/ui/history_screen.dart` | Two-tab view: photo history with sensor metadata, and trend line charts (pH, EC, temp, nutrients) over 7/30/90-day windows |

---

## Settings & Configuration

| Screen | File | Purpose |
|--------|------|---------|
| **ConfigListPage** | `lib/ui/config_list_page.dart` | Lists all reservoir configurations; shows active config with a green badge |
| **ConfigPage** | `lib/ui/config_page.dart` | Create/edit a reservoir config — name, volume, upload interval, macro/micro fertilizer chemical profiles (brand, N/P/K%, density), and target dosage |
| **CalibrationScreen** | `lib/ui/calibration_screen.dart` | Toggle calibration mode for individual sensors (pH, EC) or all at once; shows last-calibrated timestamps |
| **ProfilePage** | `lib/ui/profile_page.dart` | Edit logged-in user's name and email; optional password change (requires current password); redirects to login on email/password update |

---

## Shared Components

| Widget | File | Purpose |
|--------|------|---------|
| **AppFooter** | `lib/ui/widgets/app_footer.dart` | Bottom branding bar (LeafCloud logo, tagline, copyright) used on most screens |
