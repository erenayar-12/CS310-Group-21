# Commitly – Gamified Habit Tracker

## Project Overview

**Commitly** is a gamified habit-tracking mobile application designed to help users build and maintain consistent habits through motivation, accountability, and social engagement. The app combines personal habit tracking with team-based streaks, creating a unique social accountability system that encourages long-term commitment.

### Motivation

Many people struggle to maintain good habits due to:
- Lack of motivation and visible progress tracking
- Absence of accountability mechanisms
- Missing social support systems

Commitly addresses these challenges by:
- **Gamification**: Users earn XP points and track streaks as they complete habits
- **Team Streaks**: Groups of users share collective streaks, fostering social accountability
- **Progress Visualization**: Clear statistics and leaderboards show user progress
- **Real-time Updates**: Firebase integration enables live synchronization across devices

### Key Features

- ✅ **Personal Habit Management**: Add, edit, delete, and track individual habits
- ✅ **Flexible Frequency**: Configure habits as daily, weekly, or custom intervals
- ✅ **XP & Streak System**: Earn experience points and maintain streaks for motivation
- ✅ **Team Streaks**: Create groups where members share collective streaks
- ✅ **Leaderboards**: Compete with team members and track group progress
- ✅ **Statistics Dashboard**: View detailed analytics of your habit completion
- ✅ **Firebase Backend**: Real-time synchronization and cloud storage
- ✅ **Dark Mode**: Theme customization with persistent preferences

---

## Setup and Run Instructions

### Prerequisites

Before running the app, ensure you have the following installed:

1. **Flutter SDK** (version 3.35.5 or compatible)
   - Check your Flutter version: `flutter --version`
   - If needed, install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)

2. **Dart SDK** (version 3.9.2 or compatible)
   - Included with Flutter installation

3. **Development Environment**:
   - **iOS**: Xcode (for macOS) with iOS Simulator
   - **Android**: Android Studio with Android SDK and emulator
   - **VS Code** or **Android Studio** with Flutter extensions (recommended)

4. **Firebase Account**:
   - A Firebase project is already configured for this app
   - Firebase configuration files are included in the repository

### Step-by-Step Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/erenayar-12/CS310-Group-21.git
cd CS310-Group-21
```

#### 2. Install Dependencies

```bash
flutter pub get
```

This command will:
- Download all required packages listed in `pubspec.yaml`
- Install Firebase dependencies (`firebase_core`, `firebase_auth`, `cloud_firestore`)
- Install state management (`provider`)
- Install other dependencies (`sqflite`, `shared_preferences`, etc.)

#### 3. Firebase Configuration

The Firebase project is already configured with the following files:
- `android/app/google-services.json` (Android configuration)
- `ios/Runner/GoogleService-Info.plist` (iOS configuration)
- `lib/firebase_options.dart` (Flutter Firebase options)

**Note**: If you need to set up a new Firebase project:
1. Create a project in [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Run `flutterfire configure` to regenerate configuration files

#### 4. Verify Flutter Setup

```bash
flutter doctor
```

Ensure all required components are installed (Flutter SDK, Android toolchain, iOS toolchain, etc.).

#### 5. Run the Application

**For iOS Simulator:**
```bash
# List available devices
flutter devices

# Run on a specific iOS simulator
flutter run -d <device-id>
```

**For Android Emulator:**
```bash
# Start an Android emulator, then:
flutter run
```

**For a specific device:**
```bash
flutter run -d <device-id>
```

**Hot Reload**: While the app is running, press `r` in the terminal to hot reload, or `R` for a full restart.

#### 6. Build for Production

**iOS:**
```bash
flutter build ios
```

**Android:**
```bash
flutter build apk
```

---

## Testing

The project includes comprehensive test coverage with both unit tests and widget tests. All tests must pass successfully before committing code changes.

### Running Tests

**Run all tests:**
```bash
flutter test
```

**Run a specific test file:**
```bash
flutter test test/habit_test.dart
flutter test test/login_screen_test.dart
flutter test test/widget_test.dart
```

**Run tests with coverage:**
```bash
flutter test --coverage
```

### Test Files

#### 1. Unit Test: `test/habit_test.dart`
**Purpose**: Tests the core business logic of the Habit data model, ensuring data integrity and correct serialization/deserialization.

**What it covers**:
- `fromMap()` method: Verifies that Habit objects are correctly created from Map data structures (as stored in databases)
- `toMap()` method: Ensures Habit objects can be correctly converted to Map format for storage
- Round-trip conversion: Tests that converting a Habit to Map and back preserves all data correctly
- Edge cases: Handles null values, different frequency types (hourly, daily, weekly, monthly, custom), and date parsing
- Helper methods: Tests `frequencyLabel`, `remainingLabel`, and `streakLabel` for correct formatting

**Why it's important**: The Habit model is central to the app's functionality. These tests ensure that habit data can be reliably stored and retrieved from both SQLite and Firestore databases without data loss or corruption.

#### 2. Widget Test: `test/login_screen_test.dart`
**Purpose**: Tests the LoginScreen widget's UI rendering, form validation, and user interactions.

**What it covers**:
- Initial render: Verifies that the login screen displays correctly with all expected UI elements (email field, password field, login button)
- Mode toggle: Tests switching between login and signup modes, ensuring appropriate fields are shown/hidden
- Form validation: Tests email format validation and password requirements
- Password visibility: Verifies that the password visibility toggle works correctly
- Input handling: Ensures form fields accept and display user input correctly

**Why it's important**: The login screen is the first point of interaction for users. These tests ensure a smooth authentication experience and prevent UI bugs that could prevent users from accessing the app.

#### 3. Basic Widget Test: `test/widget_test.dart`
**Purpose**: Basic smoke test to verify the app can be instantiated without errors.

**What it covers**:
- App instantiation: Verifies that the CommitlyApp widget can be created successfully

**Why it's important**: Provides a quick check that the app's basic structure is correct and can be initialized.

---

## Known Limitations and Bugs

### Current Limitations

1. **Notifications**: Push notifications are not yet fully implemented. The app structure supports notifications, but the actual notification scheduling and delivery functionality is pending.

2. **Offline Mode**: While the app uses SQLite for local storage, full offline functionality with sync is not yet complete. Users need an internet connection for Firebase operations.

3. **Image Upload**: User profile images are not yet supported. The app currently displays text-based avatars (first letter of username).

4. **Data Export**: The data export feature in the profile page shows a summary dialog but does not generate downloadable files.

5. **Web Support**: The app is primarily designed for iOS and Android. Web platform support is limited and not fully tested.

### Known Issues

1. **Profile Page State**: Profile updates may not immediately reflect in the UI. Navigating away and back may be required to see changes.

2. **Homepage Rendering**: In some cases, marking a habit as done may cause brief UI flickering due to state rebuilds. This is a minor UX issue and does not affect functionality.

3. **Group Member Invitation**: Users must be registered in the app with a valid email address to be invited to groups. Invitations by email require the user to exist in the Firebase Authentication system.

### Future Improvements

- [ ] Implement push notifications for habit reminders
- [ ] Add user profile image upload functionality
- [ ] Complete offline mode with automatic sync
- [ ] Enhance data export with file download capability
- [ ] Improve profile page state management for immediate UI updates
- [ ] Optimize homepage rendering to eliminate flickering
- [ ] Add more comprehensive error handling and user feedback
- [ ] Implement badge system for achievements
- [ ] Add social sharing features

---

## Project Information

### Project Title
Commitly – Gamified Habit Tracker for Consistency and Motivation

### Course
CS310 – Mobile Application Development (Group 21)

## Group Members
| Name | Student ID |
| --- | --- |
| Eren Emir Ayar | 32206 |
| Oğuz Özbal | 32673 |
| Tuğrul Ağrikli | 23587 |
| Tulga Berke Kayhan | 27765 |
| Yekta Ata Yiğit | 34246 |

## Short Description
Commitly is a gamified habit-tracking app designed for users who try to be consistent in their personal or professional goals. Users can add and configure their habits (daily, weekly, or custom), track streaks, even receive reminders. Also users will be rewarded by earning XP points as they progress, so that users will be using the app in long term. 

Its standout feature — Team Streaks — allows groups of users to share streaks collectively as an addition, so they will feel accountable socialy and it will be harder to break streaks.

## Target Audience & Problem
Target Audience: General users — students, professionals, and anyone seeking motivation and something to push them to form consistent habits.

Problem Statement: Many people fail to sustain good habits due to lack of motivation, accountability, and progress visibility. Existing habit trackers often treat users as individuals, missing the motivational power of social commitment. Commitly solves this problem with team-based streaks and gentle gamification.

## Main Purpose
To help users stay consistent and motivated while building habits by combining progress tracking, reminders, and social accountability through team streaks.

## Core & Optional Features
| Type | Features |
| --- | --- |
| Core (MVP) | Add/Edit/Delete habits · Configure daily/weekly frequency · Reminder notifications · XP system · Streak tracking · Team streak mode |
| Optional (Nice-to-Have) | Badges · Community leaderboard · Social sharing · Firebase sync |

## Platform & Technology
- Framework: Flutter (cross-platform mobile)
- Programming Language: Dart
- Database: SQLite (for offline MVP) → Firebase Cloud for online features in later phases
- Notification System: Platform-native push notifications (Android and iOS)

## Data Storage Details
| Data Type | Description |
| --- | --- |
| Habit data | Name, description, frequency (daily/weekly), status |
| Progress data | XP points, streak count, completion history |
| Notification data | Reminder time and status |
| User data | Local profile ID, settings, (optional) Firebase UID for cloud sync |

## Unique Selling Point (USP)
Team Streaks Mode – unlike typical habit apps, Commitly introduces collaborative streaks: if one member of a team breaks the streak, everyone’s streak resets. This fosters a sense of collective responsibility and motivation, blending social commitment with self-improvement.

## Potential Challenges
| Area | Challenge |
| --- | --- |
| Framework Learning | Getting familiar with Flutter widgets and state management |
| UI Design | Creating an intuitive and attractive interface consistent across platforms |
| Streak Logic | Implementing accurate daily/weekly streak tracking with team integration |
| Notifications | Integrating cross-platform local/push notificationsOo |
| Backend/API | Ensuring smooth migration from SQLite to Firebase and sync consistency |

## GitHub Repository
- All team members added as collaborators
- Proper `.gitignore` (Flutter template) included
- Initial commit completed with project structure
- `README.md` contains project info and team details

## Coordination Roles
| Role | Member | Responsibilities |
| --- | --- | --- |
| Project Coordinator | Eren Emir Ayar | Oversees progress, scheduling, and milestones |
| Documentation & Submission Lead | Oğuz Özbal | Prepares written deliverables and handles submissions |
| Testing & QA Lead | Tuğrul Ağrikli | Tests features and ensures code quality |
| Integration & Repository Lead | Tulga Berke Kayhan | Manages Git/GitHub merges and version control |
| Presentation & Communication Lead | Yekta Ata Yiğit | Handles presentations and communication with TAs/Instructors |

