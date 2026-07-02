[Prev](./page-15-ui-screens.md)

# Use Case: Daily Monitoring by a Hydroponic Farm Operator

**Actor:** A farm operator managing one or more hydroponic reservoirs

---

## 1. Launch & Connect

The operator opens LeafCloud. The login screen auto-discovers the backend server on the local network — showing a live "Searching for server…" / "Connected" banner at the top. They log in with email and password.

---

## 2. Dashboard — Morning Check

The home screen loads the **Dashboard** immediately. The operator sees:

- **Health status** badge (HEALTHY / WARNING) and which fertilizer profile the AI detected
- **Sensor readings** — pH, EC, and water temperature
- **AI-estimated NPK** — N, P, K values in PPM derived from those sensor readings
- **AI Advisory card** — a summary, explanation, and a specific farmer action (e.g., "Add 50 mL of Macro solution")
- **Anomaly warning** — if the AI detected a sensor discrepancy, sensor cards show red borders and a warning icon
- A **crop photo** from the latest reading

The operator can pull to refresh or tap the refresh button in the app bar.

---

## 3. Nutrient Alert — Mid-day Notification

While the phone is idle, the app polls alerts every 5 minutes in the background. If nutrient levels drop below the threshold, a **local push notification** fires:

> *"LeafCloud WARNING: Tank A — Top-up required"*

The operator opens the **Nutrient Alerts** screen from the drawer. Each reservoir is listed with its alert level (critical / warning / normal). Expanding a card shows:

- The alert message
- Exact mL amounts to add — e.g., *Macro: 120 mL, Micro: 45 mL*

---

## 4. History — Trend Review

From the drawer, the operator opens **Reading History**. They select a 7, 30, or 90-day window and switch between:

- **Photos tab** — a chronological list of crop images with pH, EC, temp chips and Macro/Micro nutrient scale bars per reading
- **Trends tab** — line charts for pH, EC, water temp, and AI nutrient scale over time

---

## 5. Reservoir Setup / Config Change

A new crop cycle starts. The operator goes to **Reservoir Settings** → taps a reservoir → edits its fertilizer profile (chemical concentrations, densities, target PPM ranges) and saves it. This becomes the new active config that the dashboard and alerts use.

---

## 6. Sensor Calibration

Before taking readings, the operator goes to **Sensor Calibration**. They see the last calibration timestamp for each sensor (pH, EC) and can trigger a recalibration against the backend.

---

## 7. Add a New Staff Account

A second operator joins the farm. The admin goes to **Add New User** from the drawer and registers their account.

---

## Current Limitations (based on code)

| Feature | Status |
|---|---|
| Onboarding / guided setup for first-time users | Not implemented |
| Direct hardware control (dosing pumps, valves) | Not implemented — monitoring and advisory only |
| In-app reports export | Not implemented |
| Push notifications for pH / EC / temperature out-of-range | Not implemented — nutrient top-up alerts only |
| Help section / tooltips | Not implemented |
