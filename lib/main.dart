import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_places/firebase_options.dart';
import 'package:favorite_places/screens/auth_screen.dart';
import 'package:favorite_places/screens/places_screen.dart';
import 'package:favorite_places/screens/splash_screen.dart';
import 'package:favorite_places/screens/verify_email_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 102, 6, 247),
  surface: const Color.fromARGB(255, 56, 47, 68),
);

final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.surface,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.robotoTextTheme(),
  appBarTheme: AppBarTheme().copyWith(
    backgroundColor: colorScheme.primaryContainer,
    titleTextStyle: GoogleFonts.robotoTextTheme().titleLarge!.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.bold,
      fontSize: 24
    ),
    iconTheme: IconThemeData().copyWith(
      color: colorScheme.onPrimaryContainer,
    )
  ),
  cardTheme: CardThemeData().copyWith(
    color: colorScheme.surfaceContainer,
  )
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Places',
      theme: theme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              return const PlacesScreen();
            } else {
              return const VerifyEmailScreen();
            }
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
