[Prev](./page-9-shared-components.md) | [Next](./page-11-jwt-authentication.md)

# User Registration ("Add User")

This document describes the architectural flow and implementation details of the User Registration feature, which allows registering new user accounts from within the app.

## 1. Overview
The "Add New User" feature allows an active user to create additional accounts on the LeafCloud server. It is accessible from the navigation drawer and opens a registration form.

## 2. API Contract
The feature communicates with the user registration endpoint of the auth service:
- **Endpoint**: `POST /api/v1/auth/register`
- **Request Body (`UserCreate`)**:
  ```json
  {
    "name": "Jane Doe",
    "email": "jane@example.com",
    "password": "securepassword123"
  }
  ```
- **Response Payload (`UserResponse`)**:
  ```json
  {
    "id": 12,
    "name": "Jane Doe",
    "email": "jane@example.com"
  }
  ```

## 3. Data & Repository Layers

### A. Model Class
Registration maps the response JSON into the shared `User` class defined in `lib/models/user_model.dart`:
```dart
class User {
  final int id;
  final String name;
  final String email;
  ...
}
```

### B. Repository Interface (`lib/repositories/auth_repository_interface.dart`)
Declares the authentication contract:
```dart
abstract class IAuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<User> register(String name, String email, String password);
}
```

### C. Repository Implementation (`lib/repositories/auth_repository.dart`)
Sends a POST request with the JSON payload to the dynamic endpoint `ApiConstants.registerEndpoint` and returns the parsed `User` object.

## 4. State Management Layer (`lib/providers/auth_provider.dart`)
The `AuthProvider` implements `register(name, email, password)` which wraps the repository invocation, manages the loading state, and parses server exceptions.

## 5. UI Layer

### A. Drawer Navigation (`lib/ui/home_page.dart`)
Added a new ListTile menu option in the navigation drawer:
- **Title**: `Add New User`
- **Icon**: `Icons.person_add`
- **Action**: Opens the `RegisterPage` route.

### B. Form UI Screen (`lib/ui/register_page.dart`)
A clean, premium form containing:
- Text fields for Full Name, Email Address, and Password.
- Focus and input validation:
  - **Full Name**: Cannot be empty.
  - **Email**: Must contain `@` symbol and cannot be empty.
  - **Password**: Must be at least 6 characters in length.
- Color-coded snackbar alerts for user feedback on successful creation or error occurrences.
