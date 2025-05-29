import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'services/auth_service.dart'; // Fixed import path

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Controllers for email and password input
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false; // Show spinner when logging in
  String? _error; // Display error messages
  late final AnimationController _btnAnim; // Button press animation

  @override
  void initState() {
    super.initState();
    // Set up a quick scale animation for the login button
    _btnAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _btnAnim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Attempt email/password login
  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      // On success, go to HomePage and replace this one
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      // Handle common auth errors
      if (e.code == 'user-not-found') {
        setState(() => _error = 'No account found. Redirecting…');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SignUpPage()));
      } else if (e.code == 'wrong-password') {
        setState(() => _error = 'Wrong password, try again.');
      } else {
        setState(() => _error = e.message);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Use Google Sign-In from auth_service.dart
  Future<void> _handleGoogleSignIn() async {
    try {
      // Create an instance of AuthService instead of calling static method
      final authService = AuthService();
      final userCred = await authService.signInWithGoogle();
      if (userCred != null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        setState(() => _error = 'Google sign-in cancelled or failed');
      }
    } catch (e) {
      setState(() => _error = 'Google sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1 - _btnAnim.value; // Button scale effect

    return Scaffold(
      body: Stack(
        children: [
          // Decorative top blob
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B8E23), Color(0xFF9ACD32)],
                ),
                borderRadius: BorderRadius.circular(120),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Decorative bottom blob
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD2691E), Color(0xFFFFA07A)],
                ),
                borderRadius: BorderRadius.circular(140),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Main login form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with Y2K glow
                    Text(
                      'Closetly',
                      style: TextStyle(
                        fontFamily: 'FredokaOne',
                        fontSize: 36,
                        color: const Color(0xFF6B4F4F),
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: Colors.orangeAccent.withOpacity(0.6),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email input field
                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Password input field
                    _buildField(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    // Show error message if something went wrong
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Login button with a press animation
                    GestureDetector(
                      onTapDown: (_) => _btnAnim.forward(),
                      onTapUp: (_) {
                        _btnAnim.reverse();
                        if (!_isLoading) _loginUser();
                      },
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B4513), Color(0xFFDEB887)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                  : Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontSize: 18,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google Sign-in
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: Image.asset('assets/google_logo.png', height: 24),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No account? "),
                        GestureDetector(
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: const Color(0xFF8B4513),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black26),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build styled text field
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF6B8E23)),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF8B4513),
          fontFamily: 'OpenSans',
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5DC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
        ),
      ),
    );
  }
}
