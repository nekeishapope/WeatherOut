import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/event_card.dart';
import '../services/eventbrite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadData();
    });
  }

  String get _timeOfDayLabel {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7)   return '🌅 Dawn';
    if (hour >= 7 && hour < 12)  return '🌤 Morning';
    if (hour >= 12 && hour < 17) return '☀️ Afternoon';
    if (hour >= 17 && hour < 20) return '🌇 Evening';
    return '🌙 Night';
  }

  Future<void> _launchCoffee() async {
    final uri = Uri.parse('https://www.buymeacoffee.com/yourusername');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WeatherOut',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(_timeOfDayLabel,
                style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: _launchCoffee,
              icon: const Text('☕', style: TextStyle(fontSize: 16)),
              label: const Text('Coffee',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFDD00),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().loadData(),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Finding events near you...',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            child: CustomScrollView(
              slivers: [

                // ── Weather card ──────────────────────────────
                if (provider.weather != null)
                  SliverToBoxAdapter(
                    child: WeatherCard(weather: provider.weather!),
                  ),

                // ── Today / This Week toggle ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: SegmentedButton<EventDateRange>(
                      segments: const [
                        ButtonSegment(
                          value: EventDateRange.today,
                          label: Text('Today'),
                          icon: Icon(Icons.today),
                        ),
                        ButtonSegment(
                          value: EventDateRange.week,
                          label: Text('This Week'),
                          icon: Icon(Icons.date_range),
                        ),
                      ],
                      selected: {provider.selectedRange},
                      onSelectionChanged: (selection) {
                        provider.setDateRange(selection.first);
                      },
                    ),
                  ),
                ),

                // ── Weather-based events section ──────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    emoji: provider.weather?.weatherEmoji ?? '🎉',
                    title: 'Events For This Weather',
                    count: provider.weatherEvents.length,
                  ),
                ),

                if (provider.weatherEvents.isEmpty)
                  const SliverToBoxAdapter(child: _EmptyState(
                    message: 'No weather-based events found nearby',
                  ))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          EventCard(event: provider.weatherEvents[index]),
                      childCount: provider.weatherEvents.length,
                    ),
                  ),

                // ── Sports section ────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    emoji: '🏟',
                    title: 'Sports Events',
                    count: provider.sportsEvents.length,
                  ),
                ),

                if (provider.sportsEvents.isEmpty)
                  const SliverToBoxAdapter(child: _EmptyState(
                    message: 'No sports events found nearby',
                  ))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          EventCard(event: provider.sportsEvents[index]),
                      childCount: provider.sportsEvents.length,
                    ),
                  ),

                // ── Buy Me a Coffee footer ────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: InkWell(
                      onTap: _launchCoffee,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDD00),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFFFDD00).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('☕', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enjoying WeatherOut?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Buy me a coffee ☕',
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 13),
                                ),
                              ],
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final int count;

  const _SectionHeader({
    required this.emoji,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (count > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        message,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14),
      ),
    );
  }
}