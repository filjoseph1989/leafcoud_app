[Prev](./page-11-jwt-authentication.md) | [Next](./page-13-token-lifecycle-client.md)

# Role-Based Access Control (RBAC) Client-Side Adaptation

This document details the adaptation of the mobile client application to enforce Role-Based Access Control (RBAC) depending on whether the authenticated user holds administrative privileges.

---

## 1. Privilege Separation Logic

Users are divided into two main categories:
1. **Standard Users (`is_admin: false`)**: Granted read-only permission to dashboard telemetry, historical charts, and active configurations. Disallowed from making modifications or configuring devices.
2. **Admin Users (`is_admin: true`)**: Granted full CRUD authority over configs, sensor calibrations, and system operations.

---

## 2. Dynamic UI Adjustments

The mobile client evaluates the `isAdmin` flag on the current user session to show, hide, or disable specific UI routes and controls.

| Component | Standard User (`is_admin == false`) | Admin User (`is_admin == true`) |
| :--- | :--- | :--- |
| **Drawer: Sensor Calibration** | **Hidden** | Visible |
| **Drawer: Add New User** | **Hidden** | Visible |
| **Config: Add Tank Config FAB** | **Hidden** | Visible |
| **Config: Form TextFields** | **Read-Only** (no validator warnings) | Editable |
| **Config: Active Toggle Switch** | **Disabled** (onChanged = null) | Editable |
| **Config: Save Action Button** | **Hidden** (replaced with Read-Only banner) | Visible |
| **Calibration: Screen Toggles** | **Disabled** (onChanged = null) | Editable |

---

## 3. Why User Registration is Restricted to Admins

The user registration functionality defined in `docs/page-10-user-registration.md` (which maps to the **Add New User** drawer tile and `RegisterPage` route) is conditionally hidden from standard users because:
- **Security Precedence**: Standard users should not be allowed to spawn new credentials or accounts on the LeafCloud Server.
- **Graceful Failure**: Since the server's registration endpoint (`POST /api/v1/auth/register`) enforces authorization controls, letting a standard user submit the form would simply result in an `HTTP 403 Forbidden` API exception. Hiding this menu item avoids exposing dead-end workflows.
- Only users with `is_admin == true` see the **Add New User** tile and can register standard or admin accounts.

---

## 4. Error Handling & State Recovery

If a standard user attempts to perform a restricted operation or the server triggers a privilege validation failure:
- **User-Friendly Error**: The network layers intercept any `HTTP 403 Forbidden` status code and raise: 
  > *"Access Denied: You do not have permission to perform this action. Please contact your administrator."*
- **State Rollback**: Restricted triggers (like calibration toggle switches) use optimistic updates. On receiving a `403` error, the UI state automatically catches the exception and reverts back to its original state (e.g. toggles automatically switch back to off or on), ensuring the interface stays synchronized with the database.
