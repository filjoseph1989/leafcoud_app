# LeafCloud Mobile App

A modern Flutter application for smart hydroponics monitoring and automated nutrient management.

## Core Features

- **User Authentication**: Secure login with backend integration and session management.
- **Auto-Discovery**: Automatic server identification using mDNS (Zeroconf) on the local network.
- **Real-time Dashboard**: Live monitoring of pH, EC, and temperature with actionable AI top-up advice.
- **Alert Notifications**: 5-minute background polling for nutrient issues with local push notifications.
- **Reservoir Management**: Full CRUD for managing multiple tanks and fertilizer profiles.
- **Historical Trends**: Visual charts for tracking sensor data over time.
- **Responsive Design**: Custom brand theme optimized for mobile and desktop screens.

## Documentation

Comprehensive guides for each feature:

1. [Login & Authentication](docs/page-1-login-app.md)
2. [Auto-Discovery (mDNS)](docs/page-2-auto-discovery.md)
3. [App Structure & Navigation](docs/page-3-home-page.md)
4. [Reservoir Configuration](docs/page-4-system-config.md)
5. [Monitoring Dashboard](docs/page-5-dashboard.md)
6. [Alert Polling & Notifications](docs/page-6-alert-notifications.md)
7. [Reading History](docs/page-7-reading-history.md)
8. [Sensor Calibration](docs/page-8-sensor-calibration.md)
9. [Shared UI Components](docs/page-9-shared-components.md)
10. [User Registration](docs/page-10-user-registration.md)
11. [JWT Authentication](docs/page-11-jwt-authentication.md)
12. [Role-Based Access Control](docs/page-12-role-based-access-control.md)
13. [Token Lifecycle Management](docs/page-13-token-lifecycle-client.md)
14. [Account Lifecycle Management](docs/page-14-account-lifecycle-client.md)

## Development

### Prerequisites
- Flutter SDK (^3.11.5)
- Android Studio / VS Code with Flutter extension
- Access to a LeafCloud Backend server on the same WiFi

### Setup
1. Clone the repository.
2. Run `flutter pub get`.
3. Ensure your backend server is running and broadcasting its service.
4. Run `flutter run`.


![alt text](image.png)



![alt text](image-1.png)