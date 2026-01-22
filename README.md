# WakeLog

An iOS app designed to help seniors (and their caregivers) track nighttime wake-ups and their causes. Built with SwiftUI for iOS 17+.

## Purpose

WakeLog provides a simple way for senior adults who may have cognitive issues (such as Parkinson's Disease) to log what woke them up during the night. Caregivers and specialists can then review the data to identify patterns and address sleep issues.

## Features

### Log Wake-Ups
- Large, easy-to-tap checkboxes for common wake-up reasons
- Color-coded reasons for easy identification
- "Other" option with text input for custom reasons
- Big "Log Wake-Up" button with visual confirmation
- Timestamps automatically recorded

### History
- View all logged wake-ups with timestamps and reasons
- Swipe to delete individual entries
- Export to CSV for analysis in Excel or Google Sheets
- Share via email, messages, or save to files

### Charts
- Bar chart visualization of wake-up causes
- Filter by time period: Week, Month, Year, All Time
- Sorted by frequency with color-coded bars

### Options
- Customize wake-up reasons (add, edit, delete, reorder)
- Maximum of 6 custom reasons plus "Other"
- "Other" always appears last and cannot be removed
- Deleted reasons are preserved in historical logs

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Building

### Command Line

```bash
# Build
./scripts/build.sh

# Install to simulator
./scripts/install.sh

# Run in simulator
./scripts/run.sh

# All-in-one: build, install, run
./scripts/dev.sh

# Quick syntax check
./scripts/typecheck.sh

# Clean build artifacts
./scripts/clean.sh
```

### Xcode

Open `WakeLog.xcodeproj` in Xcode and run on a simulator or device.

## Project Structure

```
WakeLog/
├── scripts/              # Build and run scripts
├── WakeLog/
│   ├── WakeLogApp.swift      # App entry point
│   ├── ContentView.swift     # Tab navigation
│   ├── LogView.swift         # Main logging screen
│   ├── HistoryView.swift     # Wake-up history and export
│   ├── ChartsView.swift      # Bar chart visualization
│   ├── OptionsView.swift     # Reason customization
│   ├── DataManager.swift     # Data persistence
│   ├── WakeLogEntry.swift    # Data models
│   └── Assets.xcassets/      # App icons and colors
└── WakeLog.xcodeproj/
```

## Data Storage

All data is stored locally using UserDefaults:
- Wake-up entries with timestamps and reasons
- Custom reason configurations
- Reason names are preserved in log entries even if reasons are later deleted

## License

MIT License
