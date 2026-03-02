# Implementation Plan: Bucket Control and Status Overlay

## Phase 1: Backend Integration & State Management
- [x] **Task: Extend `ApiService` for bucket control** f3bb397
    - [x] Write tests for POST request to `/control/active-bucket`
    - [x] Write tests for GET request to fetch current active bucket status
    - [x] Implement `postActiveBucket(String label)` in `ApiService`
    - [x] Implement `fetchActiveBucketStatus()` in `ApiService`
- [ ] **Task: Create `BucketControlNotifier`**
    - [ ] Write tests for state updates and polling logic
    - [ ] Implement `BucketControlNotifier` class extending `ChangeNotifier`
    - [ ] Implement start/stop polling methods (2s interval)
    - [ ] Implement `setActiveBucket(String label)` calling `ApiService`
- [ ] **Task: Register `BucketControlNotifier` in `main.dart`**
    - [ ] Add `BucketControlNotifier` to the `MultiProvider` list
- [ ] **Task: Conductor - User Manual Verification 'Phase 1: Backend Integration & State Management' (Protocol in workflow.md)**

## Phase 2: Dashboard UI Enhancement
- [ ] **Task: Implement Dashboard Control Buttons**
    - [ ] Write tests for the control panel layout and button interactions
    - [ ] Create a `GridView` or `Wrap` with 'NPK', 'Micro', 'Mix', 'Water', and 'Stop' buttons
    - [ ] Connect button `onPressed` callbacks to `BucketControlNotifier.setActiveBucket`
- [ ] **Task: Conductor - User Manual Verification 'Phase 2: Dashboard UI Enhancement' (Protocol in workflow.md)**

## Phase 3: Video Feed Status Overlay
- [ ] **Task: Enhance `VideoFeedWidget` with Status Overlay**
    - [ ] Write tests for the overlay visibility and correct text rendering
    - [ ] Add a `Stack` to `VideoFeedWidget` to layer a semi-transparent `Container` with `Text`
    - [ ] Bind the overlay text to `BucketControlNotifier.activeBucketStatus`
- [ ] **Task: Conductor - User Manual Verification 'Phase 3: Video Feed Status Overlay' (Protocol in workflow.md)**
