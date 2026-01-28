class Weather {
  final String city;
  final String country;
  final int temperature;
  final String condition; // Sunny, Cloudy, Rainy, Stormy, Snowy
  final String description;
  final int humidity;
  final double windSpeed;
  final int feelLike;
  final List<DailyForecast> forecast;
  final List<HourlyForecast> hourlyForecast; // Added

  Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.feelLike,
    required this.forecast,
    required this.hourlyForecast, // Added
  });
}

class HourlyForecast {
  final String time;
  final int temp;
  final String condition;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
  });
}

class DailyForecast {
  final String day;
  final int high;
  final int low;
  final String condition;

  DailyForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.condition,
  });
}
