class EventModel {
  final String id;
  final String name;
  final String description;
  final String url;
  final String? imageUrl;
  final DateTime? startTime;
  final String? venueName;
  final String? venueAddress;
  final bool isFree;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.imageUrl,
    this.startTime,
    this.venueName,
    this.venueAddress,
    required this.isFree,
  });

  // Original Eventbrite factory (keep for reference)
  factory EventModel.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    return EventModel(
      id: json['id'],
      name: json['name']['text'] ?? '',
      description: json['description']['text'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['logo']?['url'],
      startTime: json['start'] != null
          ? DateTime.tryParse(json['start']['local'] ?? '')
          : null,
      venueName: venue?['name'],
      venueAddress: venue != null
          ? '${venue['address']?['localized_address_display'] ?? ''}'
          : null,
      isFree: json['is_free'] ?? false,
    );
  }

  // Ticketmaster factory
  factory EventModel.fromTicketmaster(Map<String, dynamic> json) {
    // Get best image (widest one)
    final images = json['images'] as List<dynamic>? ?? [];
    images.sort((a, b) =>
        (b['width'] as int? ?? 0).compareTo(a['width'] as int? ?? 0));
    final imageUrl = images.isNotEmpty ? images.first['url'] : null;

    // Get venue info
    final venues = json['_embedded']?['venues'] as List<dynamic>? ?? [];
    final venue = venues.isNotEmpty ? venues.first : null;
    final venueName = venue?['name'];
    final city = venue?['city']?['name'] ?? '';
    final state = venue?['state']?['stateCode'] ?? '';
    final address = venue?['address']?['line1'] ?? '';
    final venueAddress = [address, city, state]
        .where((s) => s.isNotEmpty)
        .join(', ');

    // Get start time
    final dates = json['dates'];
    final startLocal = dates?['start']?['localDate'];
    final startTime = startLocal != null
        ? DateTime.tryParse(startLocal)
        : null;

    // Check if free
    final priceRanges = json['priceRanges'] as List<dynamic>?;
    final isFree = priceRanges != null
        ? priceRanges.any((p) => (p['min'] as num? ?? 1) == 0)
        : false;

    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['info'] ?? json['pleaseNote'] ?? '',
      url: json['url'] ?? '',
      imageUrl: imageUrl,
      startTime: startTime,
      venueName: venueName,
      venueAddress: venueAddress.isNotEmpty ? venueAddress : null,
      isFree: isFree,
    );
  }
}