import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  final String id;
  final String name;
  final String genre;
  final String bio;
  final String imageUrl;
  final int followers;
  final List<String> socialLinks;

  Artist({
    required this.id,
    required this.name,
    required this.genre,
    required this.bio,
    required this.imageUrl,
    required this.followers,
    required this.socialLinks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genre': genre,
      'bio': bio,
      'imageUrl': imageUrl,
      'followers': followers,
      'socialLinks': socialLinks,
    };
  }
}

class Venue {
  final String id;
  final String name;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final int capacity;

  Venue({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
    };
  }

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      capacity: map['capacity'] ?? 0,
    );
  }
}

class LineupArtist {
  final String artistId;
  final String name;
  final String genre;
  final String imageUrl;
  final String startTime;
  final String endTime;

  LineupArtist({
    required this.artistId,
    required this.name,
    required this.genre,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'name': name,
      'genre': genre,
      'imageUrl': imageUrl,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory LineupArtist.fromMap(Map<String, dynamic> map) {
    return LineupArtist(
      artistId: map['artistId'] ?? '',
      name: map['name'] ?? '',
      genre: map['genre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
    );
  }
}

class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dateTime;
  final Venue venue;
  final List<LineupArtist> lineup;
  final String? imageUrl;
  final String? artworkPath; // Used for local file picking
  final double ticketPrice;
  final String ticketUrl;
  int likes;
  bool isBookmarked;
  bool isApproved;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.lineup,
    this.imageUrl,
    required this.ticketPrice,
    required this.ticketUrl,
    this.artworkPath,
    this.likes = 0,
    this.isBookmarked = false,
    this.isApproved = false,
  });

  /// Converts the Event object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      // Store as Timestamp for better Firestore querying
      'dateTime': Timestamp.fromDate(dateTime),
      'venue': venue.toMap(),
      'lineup': lineup.map((artist) => artist.toMap()).toList(),
      'imageUrl': imageUrl,
      'ticketPrice': ticketPrice,
      'ticketUrl': ticketUrl,
      'likes': likes,
      'isApproved': isApproved,
    };
  }

  /// Creates an Event object from a Firestore Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['dateTime'] != null
          ? (map['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      venue: Venue.fromMap(map['venue'] ?? {}),
      lineup:
          (map['lineup'] as List<dynamic>?)
              ?.map(
                (item) => LineupArtist.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      imageUrl: map['imageUrl'],
      ticketPrice: (map['ticketPrice'] ?? 0.0).toDouble(),
      ticketUrl: map['ticketUrl'] ?? '',
      likes: map['likes'] ?? 0,
      isApproved: map['isApproved'] ?? false,
    );
  }
}
