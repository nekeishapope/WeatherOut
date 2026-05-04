import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/event_model.dart';
import '../services/weather_service.dart';
import '../services/eventbrite_service.dart';

class AppProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final EventbriteService _eventbriteService = EventbriteService();

  WeatherModel? weather;
  List<EventModel> events = [];
  List<EventModel> weatherEvents = [];  // weather-based events
  List<EventModel> sportsEvents = [];   // sports-only events
  bool isLoading = false;
  String? error;
  EventDateRange selectedRange = EventDateRange.week;

  void setDateRange(EventDateRange range) {
    selectedRange = range;
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final position = await _determinePosition();
      weather = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      // Fetch weather events and sports events in parallel
      final results = await Future.wait([
        _eventbriteService.getEventsByKeywords(
          keywords: weather!.eventKeywords,
          lat: position.latitude,
          lon: position.longitude,
          dateRange: selectedRange,
        ),
        _eventbriteService.getEventsByKeywords(
          keywords: weather!.sportsKeywords,
          lat: position.latitude,
          lon: position.longitude,
          dateRange: selectedRange,
        ),
      ]);

      weatherEvents = results[0];
      sportsEvents = results[1];

      // Merge, deduplicate by ID
      final seen = <String>{};
      events = [...weatherEvents, ...sportsEvents]
          .where((e) => seen.add(e.id))
          .toList();

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}