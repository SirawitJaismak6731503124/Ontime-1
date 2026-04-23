# Ontime — Minimal Routine Reminder App

A clean, minimal Flutter app for time-based habit reminders.  
Black / white / grey only. No backend. No login. Just routines.

---

## File Structure

```
ontime/
├── lib/
│   ├── main.dart                        # App entry point, initializes services
│   ├── models/
│   │   ├── routine.dart                 # Hive model for a routine
│   │   └── routine.g.dart               # Auto-generated Hive adapter
│   ├── services/
│   │   ├── storage_service.dart         # Hive CRUD operations
│   │   └── notification_service.dart    # flutter_local_notifications scheduling
│   ├── screens/
│   │   ├── home_screen.dart             # Main list of routines
│   │   └── add_routine_screen.dart      # Create new routine
│   └── widgets/
│       └── routine_tile.dart            # Single row in routine list
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml          # Notification + alarm permissions
└── pubspec.yaml
```

---

## Prerequisites

- Flutter SDK ≥ 3.0.0 — https://flutter.dev/docs/get-started/install
- Dart SDK ≥ 3.0.0 (included with Flutter)
- Android Studio or Xcode for device/emulator

Verify your setup:
```bash
flutter doctor
```

---

## Setup & Run

### 1. Clone / copy the project
```bash
cd ontime
```

### 2. Install dependencies
```bash
flutter pub get
```

> **Note:** The `routine.g.dart` file is already included in the repo.  
> You do NOT need to run `build_runner` to get started.  
> Only re-run it if you modify `routine.dart`:
> ```bash
> flutter pub run build_runner build --delete-conflicting-outputs
> ```

### 3. Run on Android
```bash
flutter run
```

Or target a specific device:
```bash
flutter devices          # list connected devices
flutter run -d <device>  # run on a specific device
```

### 4. Run on iOS
```bash
cd ios && pod install && cd ..
flutter run
```

---

## Android: Exact Alarm Permission (Android 12+)

On Android 12 (API 31) and above, the app needs the **Alarms & Reminders** permission to schedule exact alarms.

The app requests this automatically on launch. If it doesn't open automatically:

1. Go to **Settings → Apps → Ontime → Alarms & Reminders**
2. Toggle it **ON**

This is required for notifications to fire at the exact scheduled time.

---

## Building a Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Or App Bundle for Play Store:
```bash
flutter build appbundle --release
```

---

## How It Works

### Data Storage (Hive)
- Routines are stored locally in a Hive box (`routines`)
- Each `Routine` has: `id`, `title`, `hour`, `minute`, `days[]`, `isActive`
- No network connection required

### Notifications (flutter_local_notifications)
- Uses `zonedSchedule` with `DateTimeComponents.dayOfWeekAndTime`
- Each (routine × day) pair gets a unique notification ID
- Toggling a routine OFF cancels all its notifications
- Deleting a routine cancels all its notifications
- Notifications re-trigger weekly on selected days

### UI Interactions
- **Swipe left** on a routine tile to delete it
- **Toggle switch** to enable/disable a routine without deleting
- **+ button** opens the Add Routine screen
- Routines are sorted by time on the home screen

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `hive` | ^2.2.3 | Local key-value storage |
| `hive_flutter` | ^1.1.0 | Flutter integration for Hive |
| `flutter_local_notifications` | ^17.2.2 | Scheduling local push notifications |
| `timezone` | ^0.9.4 | Timezone-aware scheduling |
| `permission_handler` | ^11.3.1 | Runtime permission requests |

---

## Notes

- No time-conflict validation — overlapping routines are allowed by design
- Notifications are silent by default (no custom sounds)
- The app works fully offline
- Data persists across app restarts and device reboots
