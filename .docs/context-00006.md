[Main](/context/context-00000.md) | [Previous](/context/context-00005.md)

# Xcode Troubleshooting & Maintenance

This document details the steps taken to resolve Xcode-related issues identified by `flutter doctor` and provides guidance on maintaining the iOS/macOS development environment.

## 1. Actions Taken to Fix Xcode Issues

While `flutter doctor` initially reported issues with Xcode, the following maintenance commands were executed to ensure the environment is correctly configured:

*   **First Launch & License:** Ran the following to ensure Xcode is initialized and licenses are accepted:
    ```bash
    sudo xcodebuild -runFirstLaunch
    sudo xcodebuild -license accept
    ```
*   **Active Developer Path:** Verified the active developer directory is set correctly to the main Xcode installation:
    ```bash
    xcode-select --print-path
    # Output: /Applications/Xcode.app/Contents/Developer
    ```
*   **CocoaPods:** Verified `cocoapods` is installed and up-to-date (Version 1.16.2), which is essential for managing iOS/macOS dependencies.

## 2. Understanding the "Simulator Runtimes" Warning

If `flutter doctor` still shows:
`✗ Unable to get list of installed Simulator runtimes.`

This typically means that while Xcode is installed, no specific iOS Simulator runtimes (e.g., iOS 17.0, iOS 18.0) have been downloaded and installed within Xcode yet.

### How to resolve this (if iOS testing is needed):
1.  Open **Xcode**.
2.  Go to **Settings** (Cmd + ,).
3.  Navigate to the **Platforms** tab.
4.  Click the **+** button or the "Get" button next to an iOS version to download the simulator runtime.

**Note:** Since this project is currently focused on macOS and Web development, this warning does not prevent you from building and running the application on your Mac or in Chrome.

## 3. Useful Xcode CLI Commands

*   **List Devices & Simulators:** `xcrun simctl list devices`
*   **Manually open Simulator:** `open -a Simulator`
*   **Reset Flutter Configuration:** `flutter config --clear-features` (used to ensure default settings are applied).

[Next](/context/context-00007.md)
