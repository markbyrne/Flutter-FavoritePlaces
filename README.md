# Flutter Favorite Places

A full-featured Flutter mobile application that allows users to capture, save, and manage their favorite locations with photos and geolocation data. This project demonstrates enterprise-level mobile development practices with Firebase backend integration and native device features.

## Features

### Core Functionality
- **Photo Capture & Management**: Take photos directly from the device camera or select from gallery with automatic quality optimization and cloud storage
- **Geolocation Services**: Capture precise location coordinates with automatic address resolution using Google Maps Geocoding API
- **Interactive Maps**: Display saved locations on static map previews with Google Maps integration
- **User Authentication**: Secure email/password authentication with email verification flow
- **Real-time Data Sync**: Instant synchronization of places across devices using Firebase Firestore
- **Dismissible List Items**: Swipe-to-delete functionality with undo capability
- **Offline Persistence**: Local data caching for seamless offline access

### User Experience
- **Responsive Form Validation**: Real-time input validation with helpful error messages
- **Loading States**: Visual feedback during asynchronous operations (uploads, authentication, data fetching)
- **Error Handling**: Graceful error handling with user-friendly snackbar notifications
- **Smooth Navigation**: Intuitive page routing between screens with proper state management
- **Modal Interfaces**: Bottom sheet for image source selection (camera vs. gallery)
- **Custom Theming**: Consistent Material Design 3 theme with dark mode support

## Technical Skills Demonstrated

### Flutter & Dart
- **State Management**: StatefulWidget lifecycle management with proper controller patterns
- **Custom Controllers**: Reusable controller pattern for form components (UserImagePicker, LocationInput)
- **Async/Await**: Proper asynchronous programming with Future handling and error management
- **Stream Builders**: Real-time UI updates using Firestore snapshots
- **Form Validation**: Complex form validation with custom validators
- **Platform Detection**: Cross-platform code with web/mobile conditional rendering

### Firebase Integration
- **Firebase Authentication**: User registration, login, email verification, and session management
- **Cloud Firestore**: NoSQL database with nested collections for user-specific data
- **Firebase Storage**: Image upload with metadata, organized folder structure, and download URL generation
- **Firebase Functions**: Backend cleanup of orphaned images (implemented separately)
- **Security**: Proper user-based data isolation and authentication state management

### Native Device Features
- **Camera Access**: Integration with device camera using image_picker plugin
- **Photo Gallery**: Access to device photo library
- **Location Services**: GPS location retrieval with permission handling
- **Permission Management**: Runtime permission requests for camera and location

### API Integration
- **Google Maps Geocoding API**: Reverse geocoding to convert coordinates to human-readable addresses
- **Google Maps Static API**: Generate static map images for location previews
- **RESTful HTTP Requests**: Proper API calls with error handling using the http package

### Architecture & Best Practices
- **Separation of Concerns**: Clear separation between models, screens, and widgets
- **Error Handling**: Comprehensive try-catch blocks with timeout handling
- **Loading States**: Proper UI feedback during async operations
- **Memory Management**: Proper disposal of controllers and resources
- **Code Organization**: Well-structured file hierarchy and naming conventions
- **Logging**: Strategic use of developer logs for debugging

### UI/UX Design
- **Material Design 3**: Modern UI following Material Design guidelines
- **Responsive Layouts**: Adaptive layouts using SingleChildScrollView and flexible containers
- **Custom Theming**: Centralized theme configuration with ColorScheme
- **Visual Feedback**: Loading indicators, fade-in images, and smooth transitions
- **Accessibility**: Proper semantic structure and color contrast

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase account
- Google Cloud Platform account (for Maps API)

### 1. Google Maps API Configuration

1. Visit the [Google Cloud Console](https://console.cloud.google.com/google/maps-apis/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps Static API
   - Geocoding API
4. Create API credentials and copy your API key
5. Create a `secrets.dart` file in the `lib` folder:

```dart
class Secrets {
  static const googleMapAPIKey = 'YOUR-API-KEY-HERE';
}
```

### 2. Firebase Configuration

Follow the [official Firebase Flutter setup guide](https://firebase.google.com/docs/flutter/setup?platform=ios) to:

1. Create a Firebase project
2. Register your app (iOS/Android/Web)
3. Download and add configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Run `flutterfire configure` to generate `firebase_options.dart`

### 3. Firebase Services Setup

Enable the following Firebase services in your Firebase Console:

- **Authentication**: Enable Email/Password sign-in method
- **Cloud Firestore**: Create database with the following security rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{uid} {
    	allow create: if request.auth != null && request.auth.uid == uid;
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /place_lists/{uid}/places/{placeId} {
    	allow create: if request.auth != null && request.auth.uid == uid;
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    
    // Deny all other documents by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```
- **Firebase Storage**: Enable with appropriate security rules for user-specific folders
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
		match /place_images/{uid}/{imageId} {
      allow create: if request.auth != null 
                    && request.auth.uid == uid
                    && request.resource.size < 5 * 1024 * 1024
                    && request.resource.contentType.matches('image/.*');
      
      allow read: if request.auth != null && request.auth.uid == uid;
      
      allow update, delete: if request.auth != null && request.auth.uid == uid;
    }
    // Deny all other requests
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### 4. Run the Application

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── models/           # Data models (Place, PlaceLocation)
├── screens/          # Application screens
├── widgets/          # Reusable UI components
├── firebase_options.dart
├── secrets.dart      # API keys (not in version control)
└── main.dart         # Application entry point
```

## Dependencies

Key packages used in this project:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `image_picker` - Camera and gallery access
- `location` - GPS location services
- `google_fonts` - Custom typography
- `http` - API requests
- `uuid` - Unique identifier generation

## Future Enhancements

- Interactive map picker for manual location selection
- Place editing functionality
- Search and filter capabilities
- Photo gallery view
- Sharing places with other users
- Category organization

---

**Note**: This is a demonstration project showcasing mobile development skills. API keys and Firebase configuration must be set up individually for security purposes.
