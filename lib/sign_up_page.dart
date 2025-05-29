import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

// Where new users come to create their account
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text input controllers - like clipboard holders for user input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  // Keep track of what's happening
  bool _isLoading = false;        // Are we creating the account right now?
  String? _errorMessage;         // Any problems to show the user?

  // Try to create a new user account
  Future<void> _signUpUser() async {
    // Clear any old errors and show we're working
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Make sure passwords match before we try anything
    if (_passwordController.text.trim() != _confirmController.text.trim()) {
      setState(() {
        _errorMessage = "Passwords do not match.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Ask Firebase to create the account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Success! Take them to the main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Something went wrong - show the error
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      // Always stop the loading spinner
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            // Nice card container for the form
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page title
                    const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Email input
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password input (hidden text)
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm password input (also hidden)
                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Confirm Password"),
                    ),
                    const SizedBox(height: 16),
                    
                    // Show error messages if something went wrong
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    
                    // Create account button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpUser, // Disable while loading
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.brown.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white) // Show spinner
                            : const Text("Create Account"), // Show text
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
