import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:soundguide_app/models/event_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExplorerProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Set<String> _followedArtistIds = {};
  final Set<String> _likedEventIds = {};
  final Set<String> _bookmarkedEventIds = {};

  bool isEventLiked(String id) => _likedEventIds.contains(id);
  bool isEventBookmarked(String id) => _bookmarkedEventIds.contains(id);

  Set<String> get followedArtistIds => _followedArtistIds;

  final List<Artist> _artists = [
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
  ];

  List<Artist> get artists => _artists;

  // --- STREAMS ---

  Stream<Event> getEventStream(String eventId) {
    return _db.collection('events').doc(eventId).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Event not found");
      return Event.fromMap(doc.data()!);
    });
  }

  void toggleLikeEvent(String eventId) {
    final docRef = _db.collection('events').doc(eventId);

    if (_likedEventIds.contains(eventId)) {
      _likedEventIds.remove(eventId);
      docRef.update({'likes': FieldValue.increment(-1)});
    } else {
      _likedEventIds.add(eventId);
      docRef.update({'likes': FieldValue.increment(1)});
    }
    notifyListeners();
  }

  void toggleBookmarkEvent(String eventId) {
    if (_bookmarkedEventIds.contains(eventId)) {
      _bookmarkedEventIds.remove(eventId);
    } else {
      _bookmarkedEventIds.add(eventId);
    }
    notifyListeners();
  }

  // For Event Goers (Only shows approved)
  Stream<List<Event>> get approvedEventsStream => _db
      .collection('events')
      .where('isApproved', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList(),
      );

  // For Admins (THE MISSING GETTER - Shows only unapproved)
  Stream<List<Event>> get unapprovedEventsStream => _db
      .collection('events')
      .where('isApproved', isEqualTo: false)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList(),
      );

  // Stream for Admins (Shows everything)
  Stream<List<Event>> get allEventsStream => _db
      .collection('events')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList(),
      );

  Stream<List<Event>> get myEventsStream {
    final user = FirebaseAuth.instance.currentUser;

    // If no user is logged in, return an empty list
    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('events')
        .where('userId', isEqualTo: user.uid) // Only fetch my events
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList(),
        );
  }

  // --- METHODS ---

  // Logic to upload image and save event
  /// Logic to upload image (if provided) and save event to Firestore
  Future<void> addEventToFirebase(Event event, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Default to an empty string if no image is uploaded
      String downloadUrl = '';

      // 1. Only attempt upload if an image file actually exists
      if (imageFile != null) {
        // Create a unique reference path
        String filePath =
            'events/${DateTime.now().millisecondsSinceEpoch}_${event.id}.jpg';
        Reference storageRef = _storage.ref().child(filePath);

        // 2. Upload with metadata
        SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

        // Note: This might still fail if your Firebase Storage isn't set up (Blaze plan issue)
        // but the code itself is now null-safe.
        UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

        // 3. Wait for the upload to COMPLETE
        TaskSnapshot snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      // 4. Create the final object
      // If imageFile was null, imageUrl will simply be ''
      final finalEvent = Event(
        id: event.id,
        userId: event.userId,
        title: event.title,
        description: event.description,
        dateTime: event.dateTime,
        venue: event.venue,
        lineup: event.lineup,
        imageUrl: downloadUrl,
        ticketPrice: event.ticketPrice,
        ticketUrl: event.ticketUrl,
        isApproved: false, // Default to false for admin workflow
      );

      // 5. Save to Firestore
      await _db.collection('events').doc(finalEvent.id).set(finalEvent.toMap());
    } catch (e) {
      debugPrint("ADD EVENT ERROR: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Admin approval method
  Future<void> approveEvent(String eventId) async {
    try {
      await _db.collection('events').doc(eventId).update({'isApproved': true});
      notifyListeners();
    } catch (e) {
      debugPrint("Error approving event: $e");
      rethrow;
    }
  }

  // Admin decline/delete method
  Future<void> declineEvent(String eventId) async {
    try {
      await _db.collection('events').doc(eventId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint("Error declining event: $e");
      rethrow;
    }
  }

  Artist? getArtistById(String artistId) {
    try {
      return _artists.firstWhere((a) => a.id == artistId);
    } catch (e) {
      return null;
    }
  }

  List<Artist> getFollowedArtists() {
    return _artists.where((a) => _followedArtistIds.contains(a.id)).toList();
  }

  void toggleFollowArtist(String artistId) {
    if (_followedArtistIds.contains(artistId)) {
      _followedArtistIds.remove(artistId);
    } else {
      _followedArtistIds.add(artistId);
    }
    notifyListeners();
  }
}
