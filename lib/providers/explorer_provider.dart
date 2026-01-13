import 'package:flutter/foundation.dart';
import 'package:soundguide_app/models/event_models.dart';

class ExplorerProvider extends ChangeNotifier {
  final Set<String> _bookmarkedEventIds = {};
  final Set<String> _followedArtistIds = {};
  final Map<String, int> _eventLikes = {}; // eventId -> like count
  final Set<String> _createdEventIds = {}; // Track events created by organiser

  // Mock data
  late List<Event> _events;
  late List<Artist> _artists;

  ExplorerProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock venues
    final technoClub = Venue(
      id: 'venue-1',
      name: 'Electric Haven',
      location: 'Downtown',
      address: '123 Main St, City',
      latitude: 40.7128,
      longitude: -74.0060,
      capacity: 2000,
    );

    final outdoorVenue = Venue(
      id: 'venue-2',
      name: 'Sunset Park',
      location: 'Waterfront',
      address: '456 Beach Ave, City',
      latitude: 40.7580,
      longitude: -73.9855,
      capacity: 5000,
    );

    // Mock artists
    _artists = [
      Artist(
        id: 'artist-1',
        name: 'Luna Echo',
        genre: 'Techno',
        bio: 'Pioneering electronic music artist with a hypnotic sound.',
        imageUrl: '🎤',
        followers: 15000,
        socialLinks: ['@lunaecho'],
      ),
      Artist(
        id: 'artist-2',
        name: 'Sonic Drift',
        genre: 'House',
        bio: 'High-energy house producer pushing boundaries.',
        imageUrl: '🎧',
        followers: 22000,
        socialLinks: ['@sonicdrift'],
      ),
      Artist(
        id: 'artist-3',
        name: 'Neon Pulse',
        genre: 'Synthwave',
        bio: 'Retro-futuristic synth sounds from the future.',
        imageUrl: '🎹',
        followers: 18000,
        socialLinks: ['@neonpulse'],
      ),
      Artist(
        id: 'artist-4',
        name: 'Deep Vibes',
        genre: 'Deep House',
        bio: 'Smooth, soulful deep house for the late night crowd.',
        imageUrl: '🎼',
        followers: 12000,
        socialLinks: ['@deepvibes'],
      ),
    ];

    // Mock events
    _events = [
      Event(
        id: 'event-1',
        title: 'Neon Nights Festival',
        description:
            'An immersive electronic music experience featuring international DJs.',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        venue: technoClub,
        lineup: [
          LineupArtist(
            artistId: 'artist-1',
            name: 'Luna Echo',
            genre: 'Techno',
            imageUrl: '🎤',
            startTime: '22:00',
            endTime: '23:30',
          ),
          LineupArtist(
            artistId: 'artist-2',
            name: 'Sonic Drift',
            genre: 'House',
            imageUrl: '🎧',
            startTime: '23:45',
            endTime: '01:30',
          ),
        ],
        imageUrl: '🎉',
        ticketPrice: 35.0,
        ticketUrl: 'https://tickets.example.com/neon-nights',
        isApproved: true,
      ),
      Event(
        id: 'event-2',
        title: 'Sunset Vibes',
        description: 'Outdoor electronic music festival at the waterfront.',
        dateTime: DateTime.now().add(const Duration(days: 14)),
        venue: outdoorVenue,
        lineup: [
          LineupArtist(
            artistId: 'artist-3',
            name: 'Neon Pulse',
            genre: 'Synthwave',
            imageUrl: '🎹',
            startTime: '19:00',
            endTime: '20:30',
          ),
          LineupArtist(
            artistId: 'artist-4',
            name: 'Deep Vibes',
            genre: 'Deep House',
            imageUrl: '🎼',
            startTime: '20:45',
            endTime: '22:30',
          ),
        ],
        imageUrl: '🌅',
        ticketPrice: 45.0,
        ticketUrl: 'https://tickets.example.com/sunset-vibes',
      ),
    ];
  }

  // Getters
  List<Event> get events => _events.where((event) => event.isApproved).toList();
  List<Event> get unapprovedEvents =>
      _events.where((event) => !event.isApproved).toList();
  List<Artist> get artists => _artists;
  Set<String> get bookmarkedEventIds => _bookmarkedEventIds;
  Set<String> get followedArtistIds => _followedArtistIds;

  // Methods
  void toggleBookmarkEvent(String eventId) {
    final event = _events.firstWhere((e) => e.id == eventId);
    if (_bookmarkedEventIds.contains(eventId)) {
      _bookmarkedEventIds.remove(eventId);
      event.isBookmarked = false;
    } else {
      _bookmarkedEventIds.add(eventId);
      event.isBookmarked = true;
    }
    notifyListeners();
  }

  void likeEvent(String eventId) {
    _eventLikes[eventId] = (_eventLikes[eventId] ?? 0) + 1;
    final event = _events.firstWhere((e) => e.id == eventId);
    event.likes = _eventLikes[eventId]!;
    notifyListeners();
  }

  void unlikeEvent(String eventId) {
    if ((_eventLikes[eventId] ?? 0) > 0) {
      _eventLikes[eventId] = _eventLikes[eventId]! - 1;
      final event = _events.firstWhere((e) => e.id == eventId);
      event.likes = _eventLikes[eventId]!;
      notifyListeners();
    }
  }

  void toggleLikeEvent(String eventId) {
    final isLiked = (_eventLikes[eventId] ?? 0) > 0;
    if (isLiked) {
      unlikeEvent(eventId);
    } else {
      likeEvent(eventId);
    }
  }

  bool isEventLiked(String eventId) {
    return (_eventLikes[eventId] ?? 0) > 0;
  }

  void toggleFollowArtist(String artistId) {
    if (_followedArtistIds.contains(artistId)) {
      _followedArtistIds.remove(artistId);
    } else {
      _followedArtistIds.add(artistId);
    }
    notifyListeners();
  }

  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  Artist? getArtistById(String artistId) {
    try {
      return _artists.firstWhere((a) => a.id == artistId);
    } catch (e) {
      return null;
    }
  }

  List<Event> getBookmarkedEvents() {
    return _events.where((e) => _bookmarkedEventIds.contains(e.id)).toList();
  }

  List<Artist> getFollowedArtists() {
    return _artists.where((a) => _followedArtistIds.contains(a.id)).toList();
  }

  void addEvent(Event event) {
    _events.add(event);
    _createdEventIds.add(event.id);
    notifyListeners();
  }

  List<Event> getCreatedEvents() {
    return _events.where((e) => _createdEventIds.contains(e.id)).toList();
  }

  void approveEvent(String eventId) {
    final event = _events.firstWhere((e) => e.id == eventId);
    event.isApproved = true;
    notifyListeners();
  }
}
