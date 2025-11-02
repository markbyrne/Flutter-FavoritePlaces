# Flutter Favorite Places App

A new Flutter project.

## Getting Started

To run this project, you must create your own secrets.dart file in the lib folder and add the key you create [here](https://console.cloud.google.com/google/maps-apis/)

Example file:

class Secrets {
  static const googleMapAPIKey = 'YOUR-API-KEY';
}

You will also need to run through the [Firebase Setup](https://firebase.google.com/docs/flutter/setup?platform=ios) to configure your own Backend and related API keys for firebase.

## Skills
- **Native Device Features** leveraging device camera/gallery, and location services.
- **Firebase** for demo hosting, user **authentication**, image and data **backend storage**, and **Firebase Functions** for backend cleanup of orphaned images.
- **Google Maps API** to select and display a location.
- Other basic Flutter skills to include:
    - State Management
    - Page Navigation
    - Modal Views
    - Snackbar Alerts
    - Dismissible List Items
    - UI Themes