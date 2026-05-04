import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const WeatherEventsApp(),
      ),
    ),
  );
}

// Returns theme mode based on hour of day
ThemeMode getTimeBasedTheme() {
  final hour = DateTime.now().hour;
  // Dawn: 6am–7am, Day: 7am–6pm, Dusk: 6pm–8pm, Night: 8pm–6am
  if (hour >= 7 && hour < 18) return ThemeMode.light;
  return ThemeMode.dark;
}

// Returns seed color based on time of day
Color getTimeBasedSeedColor() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 7) return const Color(0xFFFF6B6B);   // Dawn - warm red
  if (hour >= 7 && hour < 12) return const Color(0xFF2F80ED);  // Morning - blue
  if (hour >= 12 && hour < 17) return const Color(0xFFFF8C42); // Afternoon - orange
  if (hour >= 17 && hour < 20) return const Color(0xFF9B59B6); // Dusk - purple
  return const Color(0xFF2C3E6B);                               // Night - deep navy
}

class WeatherEventsApp extends StatefulWidget {
  const WeatherEventsApp({super.key});

  @override
  State<WeatherEventsApp> createState() => _WeatherEventsAppState();
}

class _WeatherEventsAppState extends State<WeatherEventsApp> {
  late ThemeMode _themeMode;
  late Color _seedColor;

  @override
  void initState() {
    super.initState();
    _themeMode = getTimeBasedTheme();
    _seedColor = getTimeBasedSeedColor();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherOut',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: _lightBackground(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _darkBackground(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }

  // Light backgrounds shift warmer/cooler by time
  Color _lightBackground() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7)  return const Color(0xFFFFF3E0); // Dawn - warm cream
    if (hour >= 7 && hour < 12) return const Color(0xFFF0F7FF); // Morning - cool white
    if (hour >= 12 && hour < 17) return const Color(0xFFFFFBF0); // Afternoon - warm white
    if (hour >= 17 && hour < 20) return const Color(0xFFF5F0FF); // Dusk - lavender white
    return const Color(0xFFF0F4FF);                              // Night - blue white
  }

  // Dark backgrounds shift by time
  Color _darkBackground() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7)  return const Color(0xFF1A0F0F); // Dawn - dark red
    if (hour >= 7 && hour < 12) return const Color(0xFF0F1A2A); // Morning - dark blue
    if (hour >= 12 && hour < 17) return const Color(0xFF1A150A); // Afternoon - dark amber
    if (hour >= 17 && hour < 20) return const Color(0xFF150F1A); // Dusk - dark purple
    return const Color(0xFF080D1A);                              // Night - deep navy
  }
}