import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenWeather API key not found in .env file');
    }

    // Fetch current weather AND forecast in parallel
    final results = await Future.wait([
      http.get(Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      )),
      http.get(Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      )),
    ]);

    final currentResponse = results[0];
    final forecastResponse = results[1];

    if (currentResponse.statusCode != 200) {
      throw Exception('Failed to load weather: ${currentResponse.statusCode}');
    }

    final currentJson = jsonDecode(currentResponse.body);
    List<HourlyForecast> hourlyForecasts = [];

    if (forecastResponse.statusCode == 200) {
      final forecastJson = jsonDecode(forecastResponse.body);
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);

      // Filter forecast items to only today's remaining hours
      final list = forecastJson['list'] as List<dynamic>;
      hourlyForecasts = list
          .map((item) => HourlyForecast.fromJson(item))
          .where((f) => f.time.isAfter(now) && f.time.isBefore(endOfDay))
          .toList();
    }

    return WeatherModel.fromJson(currentJson, hourlyForecasts);
  }
}