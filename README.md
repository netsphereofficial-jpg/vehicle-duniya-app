# Vehicle Duniya

A comprehensive Flutter mobile application for vehicle and property auctions. Browse, bid, and win auctions for vehicles and properties across India.

## Features

- **Vehicle Auctions** - Browse and bid on cars, bikes, trucks, and other vehicles
- **Property Auctions** - Discover property listings and participate in auctions
- **Car Bazaar** - Direct buy/sell marketplace for vehicles
- **Real-time Bidding** - Live auction updates with Firebase
- **Push Notifications** - Stay updated on auction status and outbid alerts
- **User Profiles** - Manage your bids, watchlist, and account settings

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Flutter Bloc
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Routing**: Go Router
- **Dependency Injection**: GetIt
- **Local Storage**: Hive, Shared Preferences

## Getting Started

### Prerequisites

- Flutter SDK (3.10.3 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase project configured

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/netsphereofficial-jpg/vehicle-duniya-app.git
   cd vehicle-duniya-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android and iOS apps with the following bundle IDs:
     - Android: `com.vehicleduniya.vehicle_duniya`
     - iOS: `com.vehicleduniya.vehicleDuniya`
   - Download and add config files:
     - `google-services.json` → `android/app/`
     - `GoogleService-Info.plist` → `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── config/              # App configuration and routes
├── core/                # Core utilities, themes, and services
│   ├── di/              # Dependency injection
│   ├── services/        # App services (notifications, etc.)
│   ├── theme/           # App theming
│   └── utils/           # Utility functions
├── features/            # Feature modules
│   ├── auth/            # Authentication
│   ├── home/            # Home screen
│   ├── vehicle_auction/ # Vehicle auctions
│   ├── property_auction/# Property auctions
│   ├── car_bazaar/      # Car marketplace
│   ├── bidding/         # Bidding functionality
│   └── profile/         # User profile
└── main.dart            # App entry point
```

## Firebase Indexes

The app requires the following Firestore composite indexes:

1. **Live Auctions**: `auctions` collection
   - `isActive` (Ascending)
   - `status` (Ascending)
   - `startDate` (Descending)

2. **Upcoming Auctions**: `auctions` collection
   - `isActive` (Ascending)
   - `status` (Ascending)
   - `startDate` (Ascending)

## Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary and confidential.

## Contact

For any queries, reach out to the Vehicle Duniya team.

---

Built with Flutter
