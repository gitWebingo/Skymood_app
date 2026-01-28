import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onListTap;

  const CustomBottomNav({
    super.key,
    required this.onAddTap,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomNavClipper(),
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF262C51), // Slightly lighter than bg
                      Color(0xFF1B1D36),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onListTap,
                        icon: const Icon(Icons.list,
                            color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF48319D).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.add, size: 30, color: Color(0xFF48319D)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);

    // Smooth curve
    final double center = size.width * 0.5;
    final double curveWidth = 70.0;

    path.lineTo(center - curveWidth, 0);
    path.cubicTo(
      center - 40,
      0,
      center - 35,
      45,
      center,
      45,
    );
    path.cubicTo(
      center + 35,
      45,
      center + 40,
      0,
      center + curveWidth,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
