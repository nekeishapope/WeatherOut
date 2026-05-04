class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int pop;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as int) * 1000),
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      condition: json['weather']?[0]?['main'] as String? ?? 'Clear',
      icon: json['weather']?[0]?['icon'] as String? ?? '01d',
      humidity: json['main']?['humidity'] as int? ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      pop: (((json['pop'] as num?) ?? 0) * 100).round(),
    );
  }

  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle': return '🌧';
      case 'thunderstorm': return '⛈';
      case 'snow': return '❄️';
      case 'clear': return '☀️';
      case 'clouds': return '☁️';
      case 'mist':
      case 'fog': return '🌫';
      default: return '🌡';
    }
  }
}

class WeatherModel {
  final String city;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String icon;
  final double lat;
  final double lon;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final List<HourlyForecast> hourlyForecasts;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.icon,
    required this.lat,
    required this.lon,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.hourlyForecasts,
  });

  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    List<HourlyForecast> hourlyForecasts,
  ) {
    return WeatherModel(
      city: json['name'] as String? ?? 'Unknown City',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['main']?['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (json['main']?['temp_max'] as num?)?.toDouble() ?? 0.0,
      condition: json['weather']?[0]?['main'] as String? ?? 'Clear',
      icon: json['weather']?[0]?['icon'] as String? ?? '01d',
      lat: (json['coord']?['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['coord']?['lon'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']?['humidity'] as int? ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      visibility: json['visibility'] as int? ?? 0,
      hourlyForecasts: hourlyForecasts,
    );
  }

  // Weather-based event keywords
  List<String> get eventKeywords {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return ['jazz', 'museum', 'café', 'cozy', 'indoor', 'art'];
      case 'snow':
        return ['indoor', 'cozy', 'cinema', 'gallery', 'workshop'];
      case 'clear':
        if (temperature > 25) {
          return ['pool', 'beach', 'nightlife', 'outdoor', 'festival'];
        }
        return ['outdoor', 'market', 'hiking', 'park', 'festival'];
      case 'clouds':
        if (temperature < 10) {
          return ['networking', 'movie', 'indoor', 'social', 'comedy'];
        }
        return ['market', 'outdoor', 'food', 'music', 'fitness'];
      default:
        if (temperature < 5) {
          return ['indoor', 'networking', 'movie', 'social'];
        } else if (temperature > 28) {
          return ['beach', 'pool', 'outdoor', 'festival'];
        }
        return ['music', 'food', 'arts', 'community'];
    }
  }

  // Sports keywords — always shown regardless of weather
  List<String> get sportsKeywords => [
    'baseball',
    'basketball',
    'soccer',
    'hockey',
    'football',
    'tennis',
    'volleyball',
    'MMA',
    'wrestling',
    'golf',
  ];

  // All keywords combined for API calls
  List<String> get allKeywords => [...eventKeywords, ...sportsKeywords];

  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle': return '🌧';
      case 'thunderstorm': return '⛈';
      case 'snow': return '❄️';
      case 'clear': return temperature > 25 ? '☀️' : '🌤';
      case 'clouds': return '☁️';
      default: return '🌡';
    }
  }
}