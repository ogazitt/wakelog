# Claude Code Project Guide

## Project Overview

WakeLog is an iOS app for tracking nighttime wake-ups, designed for seniors with potential cognitive issues. The app prioritizes simplicity and large touch targets.

## Tech Stack

- **Language:** Swift 5
- **UI Framework:** SwiftUI
- **Minimum iOS:** 17.0
- **Charts:** Swift Charts framework
- **Storage:** UserDefaults with JSON encoding

## Build Commands

```bash
./scripts/build.sh      # Build the app
./scripts/dev.sh        # Build, install, and run (all-in-one)
./scripts/typecheck.sh  # Quick syntax validation
```

## Architecture

### Data Flow
- `DataManager` is an `ObservableObject` shared via `@EnvironmentObject`
- All views read from and write to `DataManager`
- Data persists to UserDefaults automatically on changes

### Key Files
- `WakeLogEntry.swift` - Data models (`WakeLogEntry`, `WakeReason`, `ReasonColors`)
- `DataManager.swift` - Persistence and business logic
- `LogView.swift` - Main UI for logging wake-ups
- `ChartsView.swift` - Bar chart visualization with period filtering

### Color System
- 7-color palette in `ReasonColors` that works in light/dark mode
- Colors assigned by position in the reasons list
- "Other" always gets the last color (lime green)

## Important Patterns

### Reason Name Preservation
Log entries store `reasonNames: [String: String]?` mapping reason IDs to names at time of logging. This ensures historical data remains readable even after reasons are deleted from Options.

### Tab Order
Log (default) → History → Charts → Options

## Testing in Simulator

The project uses iPhone 15 simulator by default. Scripts accept an optional simulator name argument:
```bash
./scripts/dev.sh "iPhone 15 Pro"
```

## Xcode Project

The `project.pbxproj` file is manually maintained. When adding new Swift files:
1. Add to PBXBuildFile section
2. Add to PBXFileReference section
3. Add to PBXGroup (WakeLog group)
4. Add to PBXSourcesBuildPhase
