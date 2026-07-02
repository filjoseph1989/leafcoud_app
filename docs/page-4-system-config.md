[Prev](./page-3-home-page.md) | [Next](./page-5-dashboard.md)

# Reservoir Configuration Management

This document describes how users manage their physical hydroponic setup within the app.

## 1. Overview
The Reservoir Configuration feature allows users to define their tank dimensions and fertilizer chemical profiles. This data is critical for the backend's AI to calculate precise N-P-K mass and generate top-up instructions.

## 2. Full CRUD Implementation
The app supports a full suite of management operations via the `/api/v1/tank-configs/` endpoints:

### A. Reservoir List (`lib/ui/config_list_page.dart`)
- Displays all configured reservoirs.
- Highlights the **Active** reservoir with a green border and checkmark icon.
- Features a **Pull-to-Refresh** mechanism to sync with the server.
- Uses a **Floating Action Button (+)** to add new configurations.

### B. Edit/Create Form (`lib/ui/config_page.dart`)
A comprehensive form that handles both new and existing configurations.
- **Reservoir Info**: Name (max 50 chars) and Water Volume (liters).
- **Active Status Toggle**: A switch to set the reservoir as the primary monitoring target.
- **Fertilizer Profiles**:
    - **Macro Profile**: Brand name and N-P-K percentages.
    - **Micro Profile**: Brand name and N-P-K percentages.
- **Dosage Targets**: Intended mL per Liter dosage for calculations.

## 3. Data & Logic Layers

### Repository Pattern (`lib/repositories/config_repository.dart`)
- Communicates with the backend using `GET`, `POST`, and `PATCH` methods.
- Includes **Robust Error Handling**: Checks for non-JSON responses and handles `500 Internal Server Errors` gracefully without crashing the app.

### State Management (`lib/providers/config_provider.dart`)
- **`configs`**: The list of all reservoirs.
- **`activeConfig`**: A computed getter that finds the reservoir marked as `is_active`.
- **`isLoading`**: Tracks API request status for UI feedback.

## 4. Database Mapping
The configuration fields map directly to the backend database schema:
| UI Field | API/DB Key | Type |
|---|---|---|
| Reservoir Name | `tank_name` | String |
| Water Volume | `water_volume_liters` | Float |
| Is Active | `is_active` | Boolean |
| Macro Brand | `macro_brand_name` | String |
| N-P-K % | `macro_n_pct`, etc. | Float |
| Density | `macro_density` (and `micro_density`) | Float |
| Target Dosage | `target_macro_dosage_mll`, etc. | Float |
