import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _gradientColors().first.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section: current weather ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City + emoji row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            weather.condition,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      weather.weatherEmoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Temperature + feels like
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w200,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 4),
                      child: Text(
                        'C',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Feels like ${weather.feelsLike.round()}°C',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'H:${weather.tempMax.round()}°  L:${weather.tempMin.round()}°',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats row: humidity, wind, visibility
                Row(
                  children: [
                    _StatChip(icon: '💧', label: '${weather.humidity}%'),
                    const SizedBox(width: 8),
                    _StatChip(
                        icon: '💨',
                        label: '${weather.windSpeed.round()} m/s'),
                    const SizedBox(width: 8),
                    _StatChip(
                        icon: '👁',
                        label:
                            '${(weather.visibility / 1000).toStringAsFixed(1)} km'),
                  ],
                ),

                const SizedBox(height: 16),

                // Event keyword chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: weather.eventKeywords
                      .map((k) => Chip(
                            label: Text(k,
                                style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white.withOpacity(0.18),
                            labelStyle:
                                const TextStyle(color: Colors.white),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────
          if (weather.hourlyForecasts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Divider(
                color: Colors.white.withOpacity(0.25),
                height: 1,
              ),
            ),

            // ── Hourly forecast strip ──────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 10),
                    child: Text(
                      'REST OF TODAY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: weather.hourlyForecasts
                          .map((f) => _HourlyItem(forecast: f))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _gradientColors() {
    switch (weather.condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF4A6FA5), const Color(0xFF2D4A7A)];
      case 'thunderstorm':
        return [const Color(0xFF3D3D5C), const Color(0xFF1A1A2E)];
      case 'snow':
        return [const Color(0xFF8BB8D4), const Color(0xFF5A8FAF)];
      case 'clear':
        return weather.temperature > 25
            ? [const Color(0xFFFF8C42), const Color(0xFFFF5733)]
            : [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
      case 'clouds':
        return [const Color(0xFF6B8FA3), const Color(0xFF4A6A7A)];
      default:
        return [const Color(0xFF6B7FA3), const Color(0xFF4A5A7A)];
    }
  }
}

// ── Hourly slot ────────────────────────────────────────────────────────────

class _HourlyItem extends StatelessWidget {
  final HourlyForecast forecast;
  const _HourlyItem({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time
          Text(
            DateFormat('h a').format(forecast.time),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Emoji
          Text(
            forecast.weatherEmoji,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 6),
          // Temp
          Text(
            '${forecast.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Rain chance
          if (forecast.pop > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${forecast.pop}%',
              style: TextStyle(
                color: Colors.lightBlueAccent.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat chip ──────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}