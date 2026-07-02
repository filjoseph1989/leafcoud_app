[Prev](./page-2-auto-discovery.md) | [Next](./page-4-system-config.md)

# Main Application Structure & Navigation

This document describes the main application shell and how users navigate between features.

## 1. Home Page Overview (`lib/ui/home_page.dart`)
The `HomePage` acts as the primary container for the application after login. Instead of being a standalone screen, it now hosts the **Dashboard** as its main content.

## 2. Navigation Drawer
The app uses a standard Material **Drawer** for high-level navigation. It includes:
- **Drawer Header**: Displays the LeafCloud branding and logo.
- **Real-time Dashboard**: Links to the main monitoring view.
- **System Configuration**: Navigates to the reservoir management list.
- **Logout**: Clears the session and returns the user to the login screen.

## 3. Feature Integration
- **Dashboard (`lib/ui/dashboard_screen.dart`)**: Embedded directly in the body of the `HomePage`. This provides the user with immediate access to lettuce monitoring data.
- **Configuration (`lib/ui/config_list_page.dart`)**: Accessible via the drawer. It allows users to manage their hardware setup.

## 4. State Management Integration
The `HomePage` and its sub-pages are wrapped in a `MultiProvider` defined in `main.dart`. This ensures that:
- **`AuthProvider`**: Manages user identity and logout logic.
- **`ConfigProvider`**: Identifies which reservoir is currently "Active".
- **`IotProvider`**: Provides real-time telemetry data for the active reservoir.

## 5. UI Layout
The `HomePage` uses a `Scaffold` with:
- **`AppBar`**: Centered "LeafCloud" title with a menu icon to open the drawer.
- **`Drawer`**: Side-navigation menu.
- **`Body`**: The `DashboardScreen` widget.
