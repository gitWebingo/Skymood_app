import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skymood/providers/weather_provider.dart';
import 'package:skymood/theme/app_theme.dart';
import 'package:skymood/widgets/weather_icon.dart';
import 'package:skymood/screens/weather_detail_screen.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesSyncProvider);
    final filteredWeather = ref.watch(filteredWeatherProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.elegantBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20)),
                    const SizedBox(width: 10),
                    Text(
                      'Weather',
                      style:
                          AppTextStyles.headlineMedium.copyWith(fontSize: 28),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (value) {
                      print(value);
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      hintText: 'Search for a city or airport',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(weatherListProvider.notifier).refreshAll(),
                  color: const Color(0xFF48319D),
                  backgroundColor: const Color(0xFF1E1E2C),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    itemCount: filteredWeather.length,
                    itemBuilder: (context, index) {
                      final weather = filteredWeather[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        WeatherDetailScreen(weather: weather)));
                          },
                          child: SizedBox(
                            height: 210,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipPath(
                                    clipper: CardShapeClipper(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient:
                                            _getCardGradient(weather.condition),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    '${weather.temperature}°',
                                                    style: AppTextStyles
                                                        .headlineLarge
                                                        .copyWith(
                                                            fontSize: 64)),
                                              ),
                                              const Spacer(),
                                              Text(
                                                  'H:${weather.forecast[0].high}° L:${weather.forecast[0].low}°',
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                          color: Colors.white70,
                                                          fontSize: 16)),
                                              Text(
                                                  '${weather.city}, ${weather.country}',
                                                  style: AppTextStyles
                                                      .titleMedium
                                                      .copyWith(fontSize: 20)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 24,
                                  bottom: 24,
                                  child: Text(weather.condition,
                                      style: AppTextStyles.bodyMedium),
                                ),
                                Positioned(
                                  top: 25,
                                  right: 15,
                                  child: WeatherIcon(
                                      condition: weather.condition, size: 80),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getCardGradient(String condition) {
    return const LinearGradient(
      colors: [Color(0xFF3C3B6E), Color(0xFF282750)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class CardShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double r = 30;
    path.moveTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(
        size.width, size.height, size.width - r, size.height);
    path.lineTo(r, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - r);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
