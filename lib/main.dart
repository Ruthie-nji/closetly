// lib/main.dart

import 'package:closetly/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

/// Entry-point for the Closetly app.
Future<void> main() async {
  // make sure all the widget bindings are initalized before i do anything eslse
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options (Android, iOS, web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // After setup is done, launch the app
  runApp(const MyApp());
}

/// The root widget of the  application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Closetly App', // Shown in the task switcher on Android/iOS
      theme: ThemeData.from(
        // Generate a color scheme based on a single seed color for a cohesive look
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(), // Start the user at the login screen
      debugShowCheckedModeBanner:
          false, // Hide the "debug" banner in the corner
    );
  }
}
