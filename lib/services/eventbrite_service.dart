import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/event_model.dart';

class EventbriteService {
  final String _baseUrl = 'https://app.ticketmaster.com/discovery/v2';

  Future<List<EventModel>> getEventsByKeywords({
    required List<String> keywords,
    required double lat,
    required double lon,
    int radiusKm = 120,
    EventDateRange dateRange = EventDateRange.week, // ← new parameter
  }) async {
    final apiKey = dotenv.env['EVENTBRITE_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Ticketmaster API key not found in .env file');
    }

    for (final keyword in keywords) {
      try {
        final results = await _fetchEvents(
          apiKey: apiKey,
          keyword: keyword,
          lat: lat,
          lon: lon,
          radiusKm: radiusKm,
          dateRange: dateRange,
        );
        if (results.isNotEmpty) return results;
      } catch (e) {
        print('Keyword "$keyword" failed: $e');
        continue;
      }
    }

    return [];
  }

  Future<List<EventModel>> _fetchEvents({
    required String apiKey,
    required String keyword,
    required double lat,
    required double lon,
    required int radiusKm,
    required EventDateRange dateRange,
  }) async {
    // Build date range
    final now = DateTime.now();
    final startDateTime = _toTicketmasterDate(now);
    final endDateTime = dateRange == EventDateRange.today
        ? _toTicketmasterDate(DateTime(now.year, now.month, now.day, 23, 59, 59))
        : _toTicketmasterDate(now.add(const Duration(days: 7)));

    final uri = Uri.https('app.ticketmaster.com', '/discovery/v2/events.json', {
      'apikey': apiKey,
      'keyword': keyword,
      'latlong': '$lat,$lon',
      'radius': radiusKm.toString(),
      'unit': 'km',
      'sort': 'date,asc',
      'size': '20',
      'startDateTime': startDateTime,  // ← from now
      'endDateTime': endDateTime,       // ← today end OR 7 days from now
    });

    print('Ticketmaster URL: $uri');

    final response = await http.get(uri);
    print('Ticketmaster status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final embedded = data['_embedded'];
      if (embedded == null) return [];

      final events = embedded['events'] as List<dynamic>? ?? [];
      return events.map((e) => EventModel.fromTicketmaster(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Ticketmaster API key invalid');
    } else {
      throw Exception('Ticketmaster error: ${response.statusCode}');
    }
  }

  // Ticketmaster requires format: 2024-01-31T00:00:00Z
  String _toTicketmasterDate(DateTime dt) {
    return '${dt.toUtc().toIso8601String().split('.').first}Z';
  }
}

// Enum to switch between today and this week
enum EventDateRange { today, week }