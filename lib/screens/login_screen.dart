import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skymood/theme/app_theme.dart';
import 'package:skymood/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    setState(() => _isLoading = true);

    // Simulate slight delay for premium feel
    Future.delayed(const Duration(seconds: 1), () {
      if (_emailController.text == 'info@webingo.in' &&
          _passwordController.text == 'Webingo@12345') {
        _navigateToHome();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials! Please check and try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1C1B33),
      body: Stack(
        children: [
          // Background Image with subtle overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/download.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color:  Color(0xFF2E335A).withOpacity(0.8)// Dark overlay for better contrast
            ),
          ),

          // Decorative Glow Orbs

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Logo/Header Section
                    const Icon(Icons.cloud_queue_rounded,
                        size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'SkyMood',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weather Intelligence Reimagined',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Login Form Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login',
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Email Field
                              _buildElegantTextField(
                                controller: _emailController,
                                icon: Icons.alternate_email_rounded,
                                hint: 'Email Address',
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              _buildElegantTextField(
                                controller: _passwordController,
                                icon: Icons.lock_outline_rounded,
                                hint: 'Password',
                                isPassword: true,
                              ),
                              const SizedBox(height: 40),

                              // Login Button with Gradient
                              GestureDetector(
                                onTap: _isLoading ? null : _handleLogin,
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFF2E335A).withOpacity(0.95),
                                        const Color(0xFF1C1B33).withOpacity(0.98),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),

                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'CONTINUE',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Guest Login Option
                    TextButton(
                      onPressed: _navigateToHome,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(fontSize: 15),
                          children: [
                            const TextSpan(
                              text: 'Dont have account? ',
                              style: TextStyle(color: Colors.white38),
                            ),
                            TextSpan(
                              text: 'Continue as Guest',
                              style: TextStyle(
                                color:   Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          )
        ],
      ),
    );
  }

  Widget _buildElegantTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white38, size: 22),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
