# Countdown App

A cross-platform mobile countdown application built with **Flutter**.  
The app allows users to create countdown events, choose a target date and time, and see exactly how much time remains until each event.

This project is designed to practice working with user input, navigation between screens, persistent local data, scheduled notifications, and reusable UI components.

## Features

### Core Features

- Create a countdown event with a custom name
- Select a target date and time
- View all active countdown events
- Open an event to see its countdown
- Display the remaining days and hours
- Automatically update countdown values
- Store events locally so they remain available after restarting the app
- Delete countdown events

### Planned / Extra Features

- Archive completed events
- Schedule reminder notifications before an event
- Choose how many days before the event a reminder should be sent
- Customize events with colors and emojis
- Add custom background images
- Edit existing countdown events
- Add an iOS or Android home-screen widget

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- An Android emulator, iOS simulator, or a physical device

### Run the app

```bash
flutter pub get
flutter run
```

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
├── services/              # Notifications and other platform services
├── screens/
│   ├── home/              # Active countdown list
│   ├── create_event/      # New countdown form
│   ├── countdown/         # Countdown details
│   └── archive/           # Past events
└── widgets/               # Reusable UI components
```
