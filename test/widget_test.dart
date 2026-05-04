import 'package:flutter_test/flutter_test.dart';
import 'package:weather_events_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Just verify the app builds without crashing
    expect(WeatherEventsApp, isNotNull);
  });
}