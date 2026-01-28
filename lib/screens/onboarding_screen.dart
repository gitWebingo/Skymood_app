import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skymood/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      titlePart1: 'Explore the',
      titleHighlight: 'Sky',
      titlePart2: 'with SkyMood',
      description:
          'Get real-time weather updates with stunning animations and deep insights.',
      image: 'assets/onboarding_1.png',
      accentColor: const Color(0xFFDDB130),
    ),
    OnboardingItem(
      titlePart1: 'Detailed',
      titleHighlight: 'Forecast',
      titlePart2: 'insights',
      description:
          'Check 7-day weather predictions and hourly trends to plan your week perfectly.',
      image: 'assets/onboarding_2.png',
      accentColor: const Color(0xFF957AFF),
    ),
    OnboardingItem(
      titlePart1: 'Weather',
      titleHighlight: 'Alerts',
      titlePart2: 'stay safe',
      description:
          'Stay ahead of the storm with instant severe weather notifications and safety tips.',
      image: 'assets/onboarding_3.png',
      accentColor: Colors.orangeAccent,
    ),
    OnboardingItem(
      titlePart1: 'Premium',
      titleHighlight: 'Design',
      titlePart2: 'interface',
      description:
          'Experience a sleek glassmorphism interface designed for elegance and clarity.',
      image: 'assets/onboarding_4.png',
      accentColor: Colors.lightBlueAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E335A), // Theme-aligned top color
      body: Stack(
        children: [
          // Top Illustration Section (Patterned)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Stack(
              children: [
                // Wavy Background Decoration
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 400),
                  painter: WavePainter(),
                ),

                // Scattered Dots (Pattern from image)
                _buildDot(top: 100, left: 40, size: 8, color: Colors.white24),
                _buildDot(top: 150, right: 60, size: 12, color: Colors.white12),
                _buildDot(top: 250, left: 100, size: 6, color: Colors.white30),
                _buildDot(top: 300, right: 30, size: 10, color: Colors.white12),

                // Floating Illustrations
                PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: _items[index].accentColor.withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(140),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Image.asset(
                              _items[index].image,
                              key: ValueKey(_items[index].image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom Content Card (The "Pattern" from the image)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.48,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1B33), // Darker Navy Bottom Card
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -10),
                  )
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Title with Highlighted Span
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: RichText(
                        key: ValueKey(_currentPage),
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(
                                text: '${_items[_currentPage].titlePart1} '),
                            TextSpan(
                              text: _items[_currentPage].titleHighlight,
                              style: GoogleFonts.playfairDisplay(
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white30,
                                fontSize: 32,
                              ),
                            ),
                            TextSpan(
                                text: '\n${_items[_currentPage].titlePart2}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _items[_currentPage].description,
                        key: ValueKey(_currentPage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.white54,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Circular Progress Navigation Button
                  _buildProgressNavigation(),
                  const SizedBox(height: 15),
                  // Skip Button
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required double size,
      required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildProgressNavigation() {
    double progress = (_currentPage + 1) / _items.length;
    return GestureDetector(
      onTap: () {
        if (_currentPage < _items.length - 1) {
          setState(() => _currentPage++);
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _goToLogin();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _items[_currentPage].accentColor),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF1C1B33),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    var path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.4,
    );

    canvas.drawPath(path, paint);

    // Draw a second wave for more depth
    var path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.8,
      size.width * 0.7,
      size.height * 0.5,
    );
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.2,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingItem {
  final String titlePart1;
  final String titleHighlight;
  final String titlePart2;
  final String description;
  final String image;
  final Color accentColor;

  OnboardingItem({
    required this.titlePart1,
    required this.titleHighlight,
    required this.titlePart2,
    required this.description,
    required this.image,
    required this.accentColor,
  });
}
