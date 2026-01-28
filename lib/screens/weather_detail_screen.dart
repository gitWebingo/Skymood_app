import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skymood/models/weather_model.dart';
import 'package:skymood/widgets/weather_background.dart';
import 'package:skymood/widgets/glass_card.dart';
import 'package:skymood/widgets/weather_icon.dart';
import 'package:skymood/providers/weather_provider.dart';

class WeatherDetailScreen extends ConsumerWidget {
  final Weather weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.contains(weather.city);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.15),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.15),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(weather.city);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: WeatherBackground(
        condition: weather.condition,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 120),

              // --- HERO SECTION ---
              Column(
                children: [
                  Text(
                    weather.city,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.country.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${weather.temperature}°',
                    style: GoogleFonts.outfit(
                      fontSize: 100,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    weather.description,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'H:${weather.forecast[0].high}°   L:${weather.forecast[0].low}°',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- HOURLY SECTION ---
              _buildSectionTitle('Hourly Forecast'),
              const SizedBox(height: 20),
              _buildHourlyList(),

              const SizedBox(height: 32),

              // --- DETAILS GRID ---
              _buildSectionTitle('Atmospheric Details'),
              const SizedBox(height: 20),
              _buildDetailsGrid(),

              const SizedBox(height: 32),

              // --- WEEKLY FORECAST ---
              _buildSectionTitle('7-Day Forecast'),
              const SizedBox(height: 20),
              _buildWeeklyList(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyList() {
    return SizedBox(
      height: 145,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: weather.hourlyForecast.length,
        itemBuilder: (context, index) {
          final hour = weather.hourlyForecast[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: GlassCard(
              width: 75,
              height:
                  145, // Explicit height for GlassmorphicContainer inside ScrollView
              borderRadius: 40,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hour.time,
                    style:
                        GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                  ),
                  WeatherIcon(condition: hour.condition, size: 32),
                  Text(
                    '${hour.temp}°',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _buildDetailCard(
              Icons.water_drop_rounded, 'HUMIDITY', '${weather.humidity}%'),
          _buildDetailCard(
              Icons.air_rounded, 'WIND', '${weather.windSpeed} km/h'),
          _buildDetailCard(
              Icons.thermostat_rounded, 'FEELS LIKE', '${weather.feelLike}°'),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return GlassCard(
      width: double.infinity,
      height: 100, // Fixed height for GridView items with GlassmorphicContainer
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GlassCard(
        width: double.infinity,
        height: 400, // Explicit height estimate for the list container
        borderRadius: 30,
        padding: const EdgeInsets.all(10),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weather.forecast.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.white.withOpacity(0.05)),
          itemBuilder: (context, index) {
            final day = weather.forecast[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      day.day,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  WeatherIcon(condition: day.condition, size: 28),
                  const Spacer(),
                  Text(
                    '${day.high}°',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${day.low}°',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
