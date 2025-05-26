// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✨ THIS import is required for web (and desktop) builds:
import 'firebase_options.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'pages/my_wardrobe_page.dart';
import 'pages/friend_wardrobe_page.dart';
import 'outfit_recommendations_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 You MUST pass in your generated FirebaseOptions here:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
          if (!snapshot.hasData) {
            return const LoginPage();
          }
          return const HomePage();
        },
      ),

      routes: {
        '/login': (_) => const LoginPage(),
        '/home':  (_) => const HomePage(),
        '/my-wardrobe': (_) => MyWardrobePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/friend-wardrobe':
            final friendId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => FriendWardrobePage(friendUid: friendId),
            );
          case '/outfit-recommendations':
            final paths = settings.arguments as List<String>;
            return MaterialPageRoute(
              builder: (_) => OutfitRecommendationsPage(wardrobePaths: paths),
            );
          default:
            return null;
        }
      },
    );
  }
}
