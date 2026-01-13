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
}

class LineupArtist {
  final String artistId;
  final String name;
  final String genre;
  final String imageUrl;
  final String startTime; // e.g., "22:00"
  final String endTime; // e.g., "23:30"

  LineupArtist({
    required this.artistId,
    required this.name,
    required this.genre,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
  });
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final Venue venue;
  final List<LineupArtist> lineup;
  final String imageUrl;
  final String? artworkPath;
  final double ticketPrice;
  final String ticketUrl;
  int likes;
  bool isBookmarked;
  bool isApproved;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.lineup,
    required this.imageUrl,
    required this.ticketPrice,
    required this.ticketUrl,
    this.artworkPath,
    this.likes = 0,
    this.isBookmarked = false,
    this.isApproved = false,
  });
}
