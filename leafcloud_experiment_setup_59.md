[Previous](./leafcloud_experiment_setup_57.md) | [Next](./leafcloud_experiment_setup_59.md)

# Trash Listing API & Images Controller Refactoring (Plan)

This document outlines the plan to add a GET endpoint for listing items in the trash and refactoring image-related administrative logic into a dedicated controller.

## 1. Objective
Currently, `main.py` handles too many responsibilities, making it difficult to maintain. This plan introduces a dedicated `images_controller.py` to handle administrative image tasks, including a new endpoint for browsing trashed items via the UI.

## 2. API Specification (New Endpoint)

### List Trash Items
- **Endpoint:** `GET /api/v1/images/trash`
- **Method:** `GET`
- **Authentication:** Required (`Authorization` header).
- **Query Parameters:**
  - `skip` (int): Pagination offset (default: 0).
  - `limit` (int): Pagination limit (default: 50).
- **Response Body (List):**
  ```json
  [
    {
      "id": 1,
      "filename": "reading_Water_20260415_120000.jpg",
      "reason": "low_greenness",
      "metric_value": 34.5,
      "timestamp": "2026-04-15T12:00:00Z"
    }
  ]
  ```

## 3. Implementation Plan: Architectural Refactoring

### Step 1: Create `controllers/images_controller.py`
Establish a new `APIRouter` (prefix: `/api/v1/images`) and move the following logic from `main.py`:
- `POST /pre-filter`: Automated filtering logic.
- `POST /restore`: Trash recovery logic.
- `DELETE /{filename:path}`: Manual image deletion.
- **NEW:** `GET /trash`: The listing endpoint requested for UI integration.

### Step 2: Implement the `GET /trash` Logic
In the new controller:
- Query the `AutomatedActionLog` table.
- Filter by `action_type == "move_to_trash"`.
- Return paginated results sorted by timestamp (newest first).

### Step 3: Update `main.py`
- Remove the implementation of the moved endpoints.
- Import and include the `images_router` from `controllers/images_controller.py`.
- Ensure all necessary Pydantic models (e.g., `ImageInfo`, `TrashItemResponse`) are either shared or moved to a schema file.

### Step 4: Security Consistency
- Migrate the `authorization` header check to the new controller to ensure administrative endpoints remain protected.

## 4. Verification Plan

### Automated Testing
- Update existing tests (`test_restore_api.py`, `test_pre_filter_api.py`) to ensure they still pass with the new routing.
- Create `tests/api/test_trash_api.py` for the new listing endpoint.

### Manual Verification
1. Trigger a pre-filter to populate the `automated_action_logs`.
2. Access `GET /api/v1/images/trash` via `curl` and verify the JSON output.
3. Test a restoration using an ID retrieved from the new GET endpoint.
