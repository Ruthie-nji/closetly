// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A helper class for handling user authentication.
///
/// This service currently supports signing in with Google.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Replace with your OAuth 2.0 Client ID from Google Cloud Console
    clientId: '803028287569-b14c57toq80vrg8e5klomlc5m1vg28gi.apps.googleusercontent.com',
  );

  /// Initiates the Google Sign-In flow.
  ///
  /// Returns a [UserCredential] if successful, or null if the user cancels
  /// or an error occurs.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Prompt the user to pick a Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // If the user aborts the sign-in, we get null
      if (googleUser == null) {
        print('Google Sign-In was canceled by the user.');
        return null;
      }

      // Retrieve authentication details from the selected account
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      print('User signed in: ${userCredential.user?.displayName}');
      return userCredential;
    } catch (error) {
      // Catch and log any errors during the sign-in process
      print('Error during Google Sign-In: $error');
      return null;
    }
  }
}
