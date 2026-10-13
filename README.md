# Countdown App

A cross-platform mobile countdown application built with **Flutter**.  
The app allows users to create countdown events, choose a target date and time, and see exactly how much time remains until each event.

This project is designed to practice working with user input, navigation between screens, persistent local data, scheduled notifications, and reusable UI components.

## Features

### Countdowns

- Create a countdown event with a name, target date and time
- See all upcoming events, nearest first, with the days remaining
- Open an event to see a live countdown in days, hours, minutes and seconds
- Edit or delete events
- Completed events move to **Past events**, where they can be deleted
- Events are stored locally and remain available after restarting the app

### Customization

- Pick an emoji and a color for each event; the color tints its card
- Choose a background image from the gallery for the countdown screen

### Reminders

- Turn on a reminder for an event and choose when it is sent
  (1, 2, 3, 7, 14 or 30 days before) and at what time
- Reminders are rescheduled when an event is edited and cancelled when it is
  deleted
- On Android, reminders use inexact alarms, so they can arrive a few minutes
  after the chosen time

### Home screen widget (Android)

- Shows the nearest upcoming event with its emoji, color, days left and date
- Refreshes when events change and every hour while the app is closed
- Tapping the widget opens the app

The widget is Android only for now. An iOS widget needs a WidgetKit
extension created in Xcode.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.13
  or newer
- An Android emulator, iOS simulator, or a physical device

### Run the app

```bash
flutter pub get
flutter run
```

To try the widget on Android, long-press the home screen, open **Widgets** and
add **countdown_mobile_app**.

### Run the tests

```bash
flutter test
```

The tests cover the countdown calculations, event validation, the local event
repository, and the create and countdown list screens.

## Main Packages

| Package | Used for |
| --- | --- |
| `shared_preferences` | Storing events locally |
| `image_picker`, `path_provider` | Choosing and keeping background images |
| `flutter_local_notifications`, `timezone`, `flutter_timezone` | Scheduling reminders in the device's time zone |
| `home_widget` | Sharing the nearest event with the Android widget |

## Project Structure

```text
lib/
├── main.dart              # Entry point
├── app.dart               # MaterialApp, theme and routes
├── core/
│   ├── constants/         # Route names and app-wide constants
│   ├── theme/             # Light and dark themes
│   └── utils/             # Helper functions
├── models/                # Data models (e.g. CountdownEvent)
├── repositories/          # Local data persistence
├── services/              # Notifications, home widget and background images
├── screens/
│   ├── home/              # Active countdown list
│   ├── create_event/      # New countdown form
│   ├── countdown/         # Countdown details
│   └── archive/           # Past events
└── widgets/               # Reusable UI components

test/                      # Unit and widget tests, mirroring lib/
android/app/src/main/
├── kotlin/.../CountdownWidgetProvider.kt   # Android home screen widget
└── res/layout/countdown_widget.xml         # Widget layout
```
