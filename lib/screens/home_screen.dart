import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skymood/providers/weather_provider.dart';
import 'package:skymood/models/weather_model.dart';
import 'package:skymood/data/weather_data.dart';
import 'package:skymood/theme/app_theme.dart';
import 'package:skymood/widgets/weather_background.dart';
import 'package:skymood/widgets/weather_icon.dart';
import 'package:skymood/widgets/custom_bottom_nav.dart';
import 'package:skymood/screens/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showHourly = true;

  @override
  Widget build(BuildContext context) {
    final allWeather = ref.watch(weatherListProvider);
    final locationWeatherAsync = ref.watch(currentLocationWeatherProvider);

    return locationWeatherAsync.when(
      data: (locationWeather) {
        final Weather currentWeather = locationWeather ??
            (allWeather.isNotEmpty
                ? allWeather[0]
                : WeatherRepository.generateCityWeather('Montreal'));

        return _buildWeatherContent(context, currentWeather);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (err, stack) {
        final Weather currentWeather = allWeather.isNotEmpty
            ? allWeather[0]
            : WeatherRepository.generateCityWeather('Montreal');
        return _buildWeatherContent(context, currentWeather);
      },
    );
  }

  Widget _buildWeatherContent(BuildContext context, Weather currentWeather) {
    return Scaffold(
      extendBody: true,
      body: WeatherBackground(
        condition: currentWeather.condition,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          constraints: const BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Text(
                          currentWeather.city,
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${currentWeather.temperature}°',
                          style: GoogleFonts.outfit(
                            fontSize: 90,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          currentWeather.condition,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          'H:${currentWeather.forecast[0].high}°   L:${currentWeather.forecast[0].low}°',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(25, 60),
                            child: Image.asset(
                              'assets/weather_house-removebg-preview.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 280),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 325,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2E335A).withOpacity(0.95),
                        const Color(0xFF1C1B33).withOpacity(0.98),
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(44)),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          margin: const EdgeInsets.only(top: 12, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTab('Hourly Forecast', showHourly,
                                () => setState(() => showHourly = true)),
                            _buildTab('Weekly Forecast', !showHourly,
                                () => setState(() => showHourly = false)),
                          ],
                        ),
                      ),
                      const Divider(
                          color: Colors.white12, thickness: 1, height: 25),
                      SizedBox(
                        height: 155,
                        child: showHourly
                            ? _buildHourlyList(currentWeather.hourlyForecast)
                            : _buildWeeklyList(currentWeather.forecast),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomBottomNav(
                  onAddTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchScreen())),
                  onListTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SearchScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildHourlyList(List<HourlyForecast> hourly) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: hourly.length,
      itemBuilder: (context, index) {
        final item = hourly[index];
        final bool isActive = index == 0;

        return Container(
          width: 65,
          margin: const EdgeInsets.only(right: 15),
          decoration: isActive
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF48319D), Color(0xFF1F1D47)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.time,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              WeatherIcon(condition: item.condition, size: 28),
              const SizedBox(height: 10),
              Text(
                '${item.temp}°',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyList(List<DailyForecast> daily) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: daily.length,
      itemBuilder: (context, index) {
        final item = daily[index];
        final bool isActive = index == 0;

        return Container(
          width: 65,
          margin: const EdgeInsets.only(right: 15),
          decoration: isActive
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF48319D), Color(0xFF1F1D47)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.day,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              WeatherIcon(condition: item.condition, size: 28),
              const SizedBox(height: 10),
              Text(
                '${item.high}°',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
