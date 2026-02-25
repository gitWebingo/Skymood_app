import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skymood/models/weather_model.dart';
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class WeatherRepository {
  // URLs for Open-Meteo Geocoding and Forecast APIs
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastUrl = 'https://api.open-meteo.com/v1/forecast';

  // Fetches comprehensive real-time and forecast weather data
  static Future<Weather> fetchWeather(String cityName) async {
    try {
      // 1. Geocoding: Get coordinates for the city name
      final geoResponse = await http.get(
        Uri.parse(
            '$_geocodingUrl?name=$cityName&count=1&language=en&format=json'),
      );

      print(geoResponse.body);

      if (geoResponse.statusCode != 200) {
        throw Exception('Search service failed');
      }
      final geoData = jsonDecode(geoResponse.body);

      if (geoData['results'] == null || geoData['results'].isEmpty) {
        throw Exception('Location not found');
      }

      final result = geoData['results'][0];
      final double lat = result['latitude'];
      final double lon = result['longitude'];
      final String name = result['name'];
      final String country = result['country'] ?? 'Unknown';

      return fetchWeatherByLocation(lat, lon,
          cityName: name, countryName: country);
    } catch (e) {
      print('Open-Meteo Pipeline Error: $e');
      // Fallback to local procedural generation for immediate UX reliability
      return generateCityWeather(cityName);
    }
  }

  static Future<Weather> fetchWeatherByLocation(double lat, double lon,
      {String? cityName, String? countryName}) async {
    try {
      // 0. Reverse Geocoding: Get city name from coordinates if not provided
      if (cityName == null) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
          if (placemarks.isNotEmpty) {
            cityName = placemarks.first.locality ??
                placemarks.first.subAdministrativeArea ??
                placemarks.first.name;
            countryName = placemarks.first.country;
          }
        } catch (e) {
          print('Reverse geocoding error: $e');
        }
      }

      // 2. Weather Forecast: Current, Hourly (24h), and Daily (7d)
      final weatherResponse = await http.get(Uri.parse(
          '$_forecastUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto'));

      if (weatherResponse.statusCode != 200)
        throw Exception('Weather data failed');
      final wData = jsonDecode(weatherResponse.body);

      final current = wData['current'];
      final hourly = wData['hourly'];
      final daily = wData['daily'];

      final String currentCondition = _mapWeatherCode(current['weather_code']);

      // Map Hourly Forecast (next 24 hours starting from current hour)
      List<HourlyForecast> hourlyList = [];
      final now = DateTime.now();
      final currentHour = DateTime(now.year, now.month, now.day, now.hour);

      // Find the index that matches the current hour or is the next available
      int startIndex = 0;
      final hourlyTimes = hourly['time'] as List;
      for (int i = 0; i < hourlyTimes.length; i++) {
        final time = DateTime.parse(hourlyTimes[i]);
        if (time.isAtSameMomentAs(currentHour) || time.isAfter(currentHour)) {
          startIndex = i;
          break;
        }
      }

      for (int i = startIndex;
          i < startIndex + 24 && i < hourlyTimes.length;
          i++) {
        final timeStr = hourlyTimes[i];
        final dateTime = DateTime.parse(timeStr);
        final timeLabel = DateFormat('h a').format(dateTime).toLowerCase();

        // For the very first item (current hour), use the live "current" data
        // if it matches the current hour for better accuracy
        final isCurrentHour = i == startIndex;

        hourlyList.add(HourlyForecast(
          time: timeLabel,
          temp: isCurrentHour
              ? current['temperature_2m'].round()
              : hourly['temperature_2m'][i].round(),
          condition: isCurrentHour
              ? currentCondition
              : _mapWeatherCode(hourly['weather_code'][i]),
        ));
      }

      // Map Daily Forecast (next 7 days)
      List<DailyForecast> dailyList = [];
      for (int i = 0; i < 7; i++) {
        final timeStr = daily['time'][i];
        final dateTime = DateTime.parse(timeStr);
        final dayName = _getDayName(dateTime.weekday);

        dailyList.add(DailyForecast(
          day: dayName,
          high: daily['temperature_2m_max'][i].round(),
          low: daily['temperature_2m_min'][i].round(),
          condition: _mapWeatherCode(daily['weather_code'][i]),
        ));
      }

      return Weather(
        city: cityName ?? 'Current Location',
        country: countryName ?? '',
        temperature: current['temperature_2m'].round(),
        condition: currentCondition,
        description: _getConditionDescription(current['weather_code']),
        humidity: current['relative_humidity_2m'].round(),
        windSpeed: current['wind_speed_10m'].toDouble(),
        feelLike: current['apparent_temperature'].round(),
        forecast: dailyList,
        hourlyForecast: hourlyList,
      );
    } catch (e) {
      print('Open-Meteo Pipeline Error: $e');
      return generateCityWeather(cityName ?? 'Unknown');
    }
  }

  // Maps WMO Weather Codes to SkyMood condition strings
  static String _mapWeatherCode(int code) {
    if (code == 0) return 'Sunny';
    if (code <= 3) return 'Cloudy'; // Partly cloudy, overcast
    if (code <= 48) return 'Cloudy'; // Fog, mist
    if (code <= 67) return 'Rainy'; // Drizzle, rain
    if (code <= 77) return 'Snowy'; // Snow, grains
    if (code <= 82) return 'Rainy'; // Showers
    if (code <= 86) return 'Snowy'; // Snow showers
    if (code <= 99) return 'Stormy'; // Thunderstorms
    return 'Sunny';
  }

  // Detailed human-readable description for current condition
  static String _getConditionDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
      case 96:
      case 99:
        return 'Stormy';
      default:
        return 'Clear';
    }
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // Generates procedurally consistent weather when offline or if search fails
  static Weather generateCityWeather(String cityName) {
    final random = Random(cityName.hashCode);
    int baseTemp = 10 + random.nextInt(20);
    return Weather(
      city: cityName,
      country: 'SkyMood Offline',
      temperature: baseTemp,
      condition: 'Sunny',
      description: 'Clear Sky',
      humidity: 50,
      windSpeed: 10.0,
      feelLike: baseTemp,
      forecast: List.generate(
          7,
          (i) => DailyForecast(
                day: _getDayName((DateTime.now().weekday + i - 1) % 7 + 1),
                high: baseTemp + 5,
                low: baseTemp - 5,
                condition: 'Sunny',
              )),
      hourlyForecast: List.generate(24, (i) {
        final forecastTime = DateTime.now().add(Duration(hours: i));
        final timeLabel = DateFormat('h a').format(forecastTime).toLowerCase();
        return HourlyForecast(
          time: timeLabel,
          temp: baseTemp + random.nextInt(4) - 2,
          condition: 'Sunny',
        );
      }),
    );
  }

  // Bulk fetcher for initial app load
  static Future<List<Weather>> getInitialWeatherData() async {
    final cities = [
      'New York',
      'London',
      'Tokyo',
      'Sydney',
      'Paris',
      'Montreal',
      'Mumbai'
    ];
    return Future.wait(cities.map((city) => fetchWeather(city)));
  }

  // Compatibility helper
  static List<Weather> getSimulatedWeatherData() => [];
}
