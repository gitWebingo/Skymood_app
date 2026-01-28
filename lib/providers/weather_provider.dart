import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skymood/models/weather_model.dart';
import 'package:skymood/data/weather_data.dart';

// Manages the main list of weather data, including defaults + dynamic favorites
class WeatherListNotifier extends StateNotifier<List<Weather>> {
  Timer? _refreshTimer;

  WeatherListNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    // 1. Load initial real-time data for starter cities
    final initialData = await WeatherRepository.getInitialWeatherData();
    state = initialData;

    // 2. Start automatic background refresh (every 10 minutes)
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      refreshAll();
    });
  }

  // Refreshes all currently loaded cities with the latest real-time data
  Future<void> refreshAll() async {
    if (state.isEmpty) return;

    final List<Weather> updatedList = [];
    for (final current in state) {
      try {
        final freshWeather = await WeatherRepository.fetchWeather(current.city);
        updatedList.add(freshWeather);
      } catch (e) {
        // If one fails, keep the old data for that city
        updatedList.add(current);
      }
    }
    state = updatedList;
  }

  // Called when favorites change to ensure we have data for them
  Future<void> ensureCitiesExist(List<String> cities) async {
    if (cities.isEmpty) return;

    final currentCityNames = state.map((w) => w.city.toLowerCase()).toSet();
    final List<Weather> updatedList = [...state];
    bool changed = false;

    for (final city in cities) {
      if (!currentCityNames.contains(city.toLowerCase())) {
        // Fetch real weather for the new city
        final weather = await WeatherRepository.fetchWeather(city);
        updatedList.add(weather);
        changed = true;
      }
    }

    if (changed) {
      state = updatedList;
    }
  }

  // Explicitly add or refresh a city (e.g. from search)
  Future<void> addOrRefreshCity(String cityName) async {
    final weather = await WeatherRepository.fetchWeather(cityName);
    final index =
        state.indexWhere((w) => w.city.toLowerCase() == cityName.toLowerCase());

    if (index != -1) {
      final newList = [...state];
      newList[index] = weather;
      state = newList;
    } else {
      state = [...state, weather];
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final weatherListProvider =
    StateNotifierProvider<WeatherListNotifier, List<Weather>>((ref) {
  return WeatherListNotifier();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredWeatherProvider = Provider<List<Weather>>((ref) {
  final allWeather = ref.watch(weatherListProvider);
  final query = ref.watch(searchQueryProvider).trim();
  final favorites = ref.watch(favoritesProvider);

  if (query.isEmpty) {
    final sorted = [...allWeather];
    sorted.sort((a, b) {
      final aFav = favorites.contains(a.city);
      final bFav = favorites.contains(b.city);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return 0;
    });
    return sorted;
  }

  final matches = allWeather.where((w) {
    return w.city.toLowerCase().contains(query.toLowerCase()) ||
        w.country.toLowerCase().contains(query.toLowerCase());
  }).toList();

  // If search matches a city exactly, prioritize it
  bool exactMatchExists =
      allWeather.any((w) => w.city.toLowerCase() == query.toLowerCase());

  if (!exactMatchExists && query.length > 2) {
    // Show a "suggested" procedurally generated instance immediately for UI feedback
    String displayCity =
        query[0].toUpperCase() + query.substring(1).toLowerCase();
    final dynamicWeather = WeatherRepository.generateCityWeather(displayCity);
    matches.insert(0, dynamicWeather);

    // Kick off real fetch in background
    Future.microtask(() {
      ref.read(weatherListProvider.notifier).addOrRefreshCity(displayCity);
    });
  }

  return matches;
});

final favoritesSyncProvider = Provider.autoDispose((ref) {
  final favorites = ref.watch(favoritesProvider);
  Future.microtask(() {
    ref.read(weatherListProvider.notifier).ensureCitiesExist(favorites);
  });
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    state = favorites;
  }

  Future<void> toggleFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.contains(city)) {
      state = state.where((c) => c != city).toList();
    } else {
      state = [...state, city];
    }
    await prefs.setStringList('favorites', state);
  }

  bool isFavorite(String city) {
    return state.contains(city);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

final favoriteWeatherListProvider = Provider<List<Weather>>((ref) {
  final allWeather = ref.watch(weatherListProvider);
  final favoriteCities = ref.watch(favoritesProvider);

  return allWeather.where((w) => favoriteCities.contains(w.city)).toList();
});

// Stream of location updates
final locationStreamProvider = StreamProvider<Position?>((ref) async* {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    yield null;
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      yield null;
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    yield null;
    return;
  }

  // Set up location settings for tracking
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5000, // Update every 5km to save battery and API calls
  );

  yield* Geolocator.getPositionStream(locationSettings: locationSettings);
});

// Provides weather for the user's current location, updating automatically as they move
final currentLocationWeatherProvider = FutureProvider<Weather?>((ref) async {
  final position = ref.watch(locationStreamProvider).value;

  if (position == null) {
    // If no stream data yet, try to get a one-time quick fix
    try {
      Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
      return await WeatherRepository.fetchWeatherByLocation(
          p.latitude, p.longitude);
    } catch (_) {
      return null;
    }
  }

  return await WeatherRepository.fetchWeatherByLocation(
      position.latitude, position.longitude);
});
