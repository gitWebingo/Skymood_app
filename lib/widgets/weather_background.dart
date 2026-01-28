import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:skymood/theme/app_theme.dart';

class WeatherBackground extends StatelessWidget {
  final String condition;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    LinearGradient gradient;
    Widget bgAnimation;

    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
      case 'clear sky':
        gradient = AppColors.sunnyDay;
        bgAnimation = const _SunAnimation();
        break;
      case 'rainy':
      case 'light rain':
        gradient = AppColors.rainyDay;
        bgAnimation = const _RainAnimation();
        break;
      case 'cloudy':
      case 'partly cloudy':
      case 'overcast':
        gradient = AppColors.cloudyDay;
        bgAnimation = const _CloudAnimation();
        break;
      case 'stormy':
      case 'thunderstorms':
        gradient = AppColors.stormyDay;
        bgAnimation = const _RainAnimation(isStorm: true);
        break;
      case 'snowy':
      case 'light snow':
        gradient = AppColors.snowyDay;
        bgAnimation = const _SnowAnimation();
        break;
      default:
        gradient = AppColors.sunnyDay;
        bgAnimation = const SizedBox();
    }

    return Stack(
      children: [
        // Base Gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
        ),

        // Animated Elements Layer
        Positioned.fill(child: bgAnimation),

        // Foreground Content
        child,
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ANIMATED WIDGETS
// -----------------------------------------------------------------------------

class _SunAnimation extends StatefulWidget {
  const _SunAnimation();
  @override
  State<_SunAnimation> createState() => _SunAnimationState();
}

class _SunAnimationState extends State<_SunAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Transform.scale(
                scale: 1.0 + (_controller.value * 0.2),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 50,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RainAnimation extends StatefulWidget {
  final bool isStorm;
  const _RainAnimation({this.isStorm = false});
  @override
  State<_RainAnimation> createState() => _RainAnimationState();
}

class _RainAnimationState extends State<_RainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainPainter(
            _controller.value,
            count: widget.isStorm ? 100 : 50,
            color: Colors.white.withOpacity(widget.isStorm ? 0.3 : 0.15),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final Color color;
  final List<Offset> _drops = [];

  _RainPainter(this.animationValue,
      {required this.count, required this.color}) {
    // Deterministic random layout based on index
    var rng = math.Random(42);
    for (int i = 0; i < count; i++) {
      _drops.add(Offset(rng.nextDouble(), rng.nextDouble()));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in _drops) {
      double startY = (drop.dy + animationValue) % 1.0;
      // Draw simulated rain drop
      double x = drop.dx * size.width;
      double y = startY * size.height;

      canvas.drawLine(Offset(x, y), Offset(x, y + 20), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}

class _SnowAnimation extends StatefulWidget {
  const _SnowAnimation();
  @override
  State<_SnowAnimation> createState() => _SnowAnimationState();
}

class _SnowAnimationState extends State<_SnowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SnowPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double animationValue;
  final List<_Snowflake> _flakes = [];

  _SnowPainter(this.animationValue) {
    var rng = math.Random(13);
    for (int i = 0; i < 100; i++) {
      _flakes.add(_Snowflake(
        relativeX: rng.nextDouble(),
        relativeY: rng.nextDouble(),
        size: 1 + rng.nextDouble() * 3,
        opacity: 0.2 + rng.nextDouble() * 0.5,
        speedMultiplier: 0.5 + rng.nextDouble() * 1.5,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var flake in _flakes) {
      final paint = Paint()..color = Colors.white.withOpacity(flake.opacity);

      double currentYProgress =
          (flake.relativeY + (animationValue * flake.speedMultiplier)) % 1.0;
      double x = flake.relativeX * size.width;

      // Add horizontal drift based on Y position
      x += math.sin((currentYProgress * math.pi * 4) + (flake.relativeX * 20)) *
          15;

      double y = currentYProgress * size.height;
      canvas.drawCircle(Offset(x, y), flake.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) => true;
}

class _Snowflake {
  final double relativeX;
  final double relativeY;
  final double size;
  final double opacity;
  final double speedMultiplier;

  _Snowflake({
    required this.relativeX,
    required this.relativeY,
    required this.size,
    required this.opacity,
    required this.speedMultiplier,
  });
}

class _CloudAnimation extends StatefulWidget {
  const _CloudAnimation();
  @override
  State<_CloudAnimation> createState() => _CloudAnimationState();
}

class _CloudAnimationState extends State<_CloudAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 60,
          left: -40,
          child: _buildCloud(0.3),
        ),
        Positioned(
          top: 120,
          right: -60,
          child: _buildCloud(0.6),
        ),
      ],
    );
  }

  Widget _buildCloud(double startValue) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        double offset =
            math.sin((_controller.value + startValue) * math.pi * 2) * 30;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Icon(Icons.cloud_rounded,
          size: 200, color: Colors.white.withOpacity(0.1)),
    );
  }
}
