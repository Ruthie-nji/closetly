// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // ← Only once
import 'login_page.dart';
import 'home_page.dart';
import 'pages/my_wardrobe_page.dart';
import 'pages/friend_wardrobe_page.dart';
import 'outfit_recommendations_page.dart'; // ← No more constructor args

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Closetly',
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

      // Show login/home based on auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Auth error:\n${snapshot.error}')),
            );
          }
          return snapshot.hasData ? const HomePage() : const LoginPage();
        },
      ),

      // Static named routes
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/my-wardrobe': (_) => MyWardrobePage(),
      },

      // Dynamic routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/friend-wardrobe':
            final friendId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => FriendWardrobePage(friendUid: friendId),
            );

          case '/outfit-recommendations':
            // We no longer take wardrobePaths through constructor
            return MaterialPageRoute(
              builder: (_) => const OutfitRecommendationsPage(),
            );

          default:
            return null;
        }
      },
    );
  }
}
