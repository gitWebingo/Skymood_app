import 'package:flutter/material.dart';

class WeatherIcon extends StatefulWidget {
  final String condition;
  final double size;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 100,
  });

  @override
  State<WeatherIcon> createState() => _WeatherIconState();
}

class _WeatherIconState extends State<WeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Helper to determine animation type/duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (widget.condition.toLowerCase()) {
      case 'sunny':
      case 'clear sky':
      case 'clear':
        iconData = Icons.wb_sunny_rounded;
        color = Colors.amber;
        break;
      case 'rainy':
      case 'light rain':
        iconData = Icons.water_drop_rounded;
        color = Colors.lightBlueAccent;
        break;
      case 'cloudy':
      case 'partly cloudy':
      case 'overcast':
        iconData = Icons.cloud_rounded;
        color = Colors.grey.shade300;
        break;
      case 'stormy':
      case 'thunderstorms':
        iconData = Icons.thunderstorm_rounded;
        color = Colors.deepPurpleAccent;
        break;
      case 'snowy':
      case 'light snow':
        iconData = Icons.ac_unit_rounded;
        color = Colors.white;
        break;
      default:
        iconData = Icons.wb_cloudy_rounded;
        color = Colors.white;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Floating/Breathing Effect
        double breathe = 0.05 * _controller.value;
        return Transform.scale(
          scale: 1.0 + breathe,
          child: Transform.translate(
            offset: Offset(0, -10 * _controller.value),
            child: child,
          ),
        );
      },
      child: Icon(
        iconData,
        size: widget.size,
        color: color,
        shadows: [
          Shadow(
            blurRadius: 30,
            color: color.withOpacity(0.6),
            offset: const Offset(0, 5),
          ),
          Shadow(
            blurRadius: 10,
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(0, 0),
          )
        ],
      ),
    );
  }
}
