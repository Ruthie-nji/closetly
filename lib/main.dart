// lib/main.dart

// This is where our app starts - like the front door of our house
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'outfit_recommendations_page.dart';

// The first thing that runs when someone opens our app
void main() async {
  // Make sure Flutter is ready to work
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Firebase (our backend service)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Closetly',

      // How our app looks and feels
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'FredokaOne',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),

      // Decide what screen to show first
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // Still figuring out if user is logged in
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Something went wrong with login check
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Auth error:\n${snapshot.error}')),
            );
          }

          // Show home page if logged in, login page if not
          final user = snapshot.data;
          return user != null ? const HomePage() : const LoginPage();
        },
      ),

      // Simple page routes (like /login, /home)
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
      },

      // More complex routes that might need extra info
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/outfit-recommendations':
            return MaterialPageRoute(
              builder: (_) => const OutfitRecommendationsPage(),
            );
          default:
            return null; // Page not found
        }
      },
    );
  }
}
