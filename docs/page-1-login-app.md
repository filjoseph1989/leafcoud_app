[Next](./page-2-auto-discovery.md)

# LoginApp Execution Flow

This document describes the architectural flow and implementation details of the LeafCloud Login application.

## 1. App Initialization (`lib/main.dart`)

**`runApp(const LoginApp())`**
The entry point of the Flutter application. It initializes the `LoginApp` widget within a `MultiProvider` for Dependency Injection.

**`MaterialApp` Configuration**
- **Title**: 'LeafCloud Login'.
- **Theme**: Uses a custom `ColorScheme` based on the brand design.
    - **Primary Seed**: Forest Green (`#4E7A43`).
    - **Surface**: Sage Green (`#D9E3D9`).
- **debugShowCheckedModeBanner**: Set to `false`.
- **Home**: Directs the app to start on the `LoginPage`.

## 2. Clean Architecture (SOLID)

The login logic follows SOLID principles and is separated into distinct layers for maintainability and testability:

### A. Data Layer (`lib/models/` & `lib/repositories/`)
- **`User` & `LoginResponse`**: Structured data models with JSON serialization.
- **`IAuthRepository`**: An abstract interface defining the authentication contract (Dependency Inversion).
- **`AuthRepository`**: Concrete implementation using the `http` package to communicate with the `/api/v1/auth/login` endpoint.

### B. State Management Layer (`lib/providers/`)
- **`AuthProvider`**: A `ChangeNotifier` that manages the login state, loading indicators, and error messages. It depends on the `IAuthRepository` interface.

### C. UI Layer (`lib/ui/`)
- **`LoginPage`**: A stateful widget that provides the form interface.
- **Validation**: Strict client-side validation for email/username and password.
- **Navigation**: Upon successful login, the app uses `Navigator.pushReplacement` to move to the `HomePage`, preventing the user from returning to the login screen.

## 3. Configuration & Infrastructure

### A. Centralized Configuration (`lib/core/constants.dart`)
Stores API endpoints and global constants. It manages the base URL dynamically.
- `baseUrl`: Defaults to `http://localhost:8000`, but is updated via the Auto-Discovery service.
- `loginEndpoint`: `/api/v1/auth/login`.

### B. Auto-Discovery Service (`lib/services/discovery_service.dart`)
Allows the app to automatically find the backend server on the local network using mDNS (Multicast DNS).

## 4. UI Implementation Details
- **Responsive Layout**: Centered `Column` wrapped in `SingleChildScrollView` for mobile compatibility.
- **Custom Styling**: 
    - Circular white container for the leaf icon logo.
    - Rounded input fields (`BorderRadius.circular(12)`) with semi-transparent white backgrounds.
    - Full-width "Login" button with `ElevatedButton.styleFrom`.
- **Desktop Adaptation**: Set fixed window dimensions (400x800) for a consistent mobile-like look.

## 5. Automated Verification (`test/widget_test.dart`)
- Verifies branding and form presence.
- Tests asynchronous UI flow (loading indicators, error handling).
