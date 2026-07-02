[Prev](./page-13-token-lifecycle-client.md) | [Next](./page-15-ui-screens.md)

# Client Integration: **Account Lifecycle Management**

This document explains the mobile application's integration of the Account Lifecycle Management workflows introduced on the backend. It describes the design patterns, screen flows, and security measures applied.

---

## 1. Overview
The LeafCloud mobile app supports complete account lifecycle management to ensure secure user activation, profile updates, and credential recovery.
The workflows integrated include:
1. **Account Verification**: Informing users that newly registered accounts are unverified and must be verified before login.
2. **Profile & Password Updates**: Providing a dedicated **My Profile** screen to edit details and change passwords, ensuring session security by instantly logging out the user if sensitive credentials (email or password) are modified.
3. **Password Recovery**: Providing a Forgot Password flow directly from the Login page that transitions from email entry to reset token consumption.

---

## 2. Technical Implementation Details

### A. Repository Layer & API Methods
We added three methods to `IAuthRepository` and implemented them in `AuthRepository`:
- **`forgotPassword(String email)`**: Calls `POST /api/v1/auth/forgot-password` to trigger password reset simulation.
- **`resetPassword(String token, String newPassword)`**: Calls `POST /api/v1/auth/reset-password` to consume the hex token and update credentials.
- **`updateProfile(String accessToken, {String? name, String? email, String? currentPassword, String? newPassword})`**: Calls `PATCH /api/v1/auth/me` with only the modified fields.

### B. State Management (`AuthProvider`)
The state layer exposes corresponding futures and enforces security constraints:
* **Token Invalidation Check**: In `updateProfile()`, we check if the user successfully changed either their email or password. If so, we invoke `logout()` immediately to clear local JWT credentials (`ApiConstants.token` and `ApiConstants.refreshToken`) and notify UI listeners to redirect to the login screen.

---

## 3. UI Flow & Layouts

### A. Forgot Password Dialog
Integrated into [login_page.dart](file:///Users/fil/Fil/leafcloud/mimeng_leafcloud_app_v2/lib/ui/login_page.dart), a "Forgot Password?" text button triggers a stateful dialog:
1. **Step 1 (Request Reset)**: Prompts for the email address. Calls `forgotPassword(email)` on submission.
2. **Step 2 (Perform Reset)**: Explains that a simulated reset token was printed to the server console. Prompts the user to enter the token and their new password. Calls `resetPassword(token, newPassword)`.

### B. Profile Management Screen
A new screen [profile_page.dart](file:///Users/fil/Fil/leafcloud/mimeng_leafcloud_app_v2/lib/ui/profile_page.dart) was created:
- Displays user card with name, email, and Admin/User role chip.
- Input fields for updating Name and Email.
- A toggle switch to expand the "Change Password" sub-form, requiring `current_password` and `new_password`.
- Validates fields and triggers profile updates. If security credentials change, navigates the user back to the LoginPage with a clear notification.

### C. Registration Verification Message
In [register_page.dart](file:///Users/fil/Fil/leafcloud/mimeng_leafcloud_app_v2/lib/ui/register_page.dart), when an Administrator creates a new account, the success snackbar informs the administrator to look at the server's stdout logs to locate the simulated email activation link (`/api/v1/auth/verify?token=...`) to activate the user's account before login.
