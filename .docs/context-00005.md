[Main](/context/context-00000.md) | [Previous](/context/context-00004.md)

# Flutter SDK Installation & CLI Usage Guide

This document summarizes the recent system changes made to enable Flutter development and provides a guide on how to manage projects using the Flutter CLI (Command Line Interface) without relying on IDE extensions.

## 1. Actions Taken

*   **SDK Installation:** The Flutter SDK (Stable channel) has been installed into `/Users/fil/flutter_sdk`.
*   **Environment Configuration:** Added the Flutter `bin` directory to the system `PATH` in `~/.zshrc`.
    *   Command added: `export PATH="$HOME/flutter_sdk/bin:$PATH"`
*   **Dependencies:** Ran `flutter pub get` to resolve and download project-specific dependencies.
*   **Verification:** Verified the installation using `flutter doctor` and successfully launched the app on macOS.

## 2. Creating a New Project via CLI

Since you are not using a VS Code extension, you can create new Flutter projects directly from your terminal:

```bash
# Navigate to the directory where you want your project
cd ~/Fil/your_projects_folder

# Create a new project
flutter create my_new_app

# Navigate into the project
cd my_new_app
```

**Common `flutter create` flags:**
*   `--org com.yourdomain`: Sets the organization identifier.
*   `--platforms ios,android,macos,web`: Specifies which platforms to support.
*   `-t app` or `-t package`: Specifies the template type (app is default).

## 3. Running and Managing Projects

Use these commands from the root directory of any Flutter project:

### Running the App
```bash
# List available devices
flutter devices

# Run on the default device
flutter run

# Run on a specific device (e.g., macOS or Chrome)
flutter run -d macos
flutter run -d chrome
```

### Managing Dependencies
```bash
# Fetch dependencies listed in pubspec.yaml
flutter pub get

# Add a new package
flutter pub add provider

# Upgrade dependencies
flutter pub upgrade
```

### Project Maintenance
```bash
# Check environment health
flutter doctor

# Clean build artifacts (useful if you encounter build errors)
flutter clean

# Analyze code for errors/warnings
flutter analyze
```

## 4. Development Workflow

Without an IDE extension, your workflow will look like this:
1.  **Edit:** Modify files in your preferred text editor.
2.  **Run:** Start the app using `flutter run -d macos` in the terminal.
3.  **Hot Reload:** While the app is running in the terminal, press **'r'** to perform a Hot Reload or **'R'** for a Hot Restart.
4.  **Debug:** View logs directly in the terminal output.

[Next](/context/context-00006.md)
