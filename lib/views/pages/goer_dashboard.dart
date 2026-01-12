import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/models/event_models.dart';
import 'package:soundguide_app/providers/auth_provider.dart';
import 'package:soundguide_app/providers/explorer_provider.dart';

class GoerDashboard extends StatefulWidget {
  const GoerDashboard({super.key});

  @override
  State<GoerDashboard> createState() => _GoerDashboardState();
}

class _GoerDashboardState extends State<GoerDashboard> {
  String _currentPage = 'events';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        title: const Text(
          'SoundGuide Explorer',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Icon(Icons.logout, color: AppColors.accent),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildCurrentPage(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.cardBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.darkBg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Text(
                      authProvider.currentUser?.displayName ?? 'Explorer',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Event Goer',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event, color: AppColors.accent),
            title: const Text(
              'Events',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            selected: _currentPage == 'events',
            selectedTileColor: AppColors.divider,
            onTap: () {
              setState(() => _currentPage = 'events');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note, color: AppColors.accent),
            title: const Text(
              'Artists',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            selected: _currentPage == 'artists',
            selectedTileColor: AppColors.divider,
            onTap: () {
              setState(() => _currentPage = 'artists');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.accent),
            title: const Text(
              'My Dashboard',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            selected: _currentPage == 'dashboard',
            selectedTileColor: AppColors.divider,
            onTap: () {
              setState(() => _currentPage = 'dashboard');
              Navigator.pop(context);
            },
          ),
          const Divider(color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.accent),
            title: const Text(
              'Account Settings',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/account-settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'events':
        return _buildEventsTab();
      case 'artists':
        return _buildArtistsTab();
      case 'dashboard':
        return _buildPersonalDashboard();
      default:
        return _buildEventsTab();
    }
  }

  Widget _buildEventsTab() {
    return Consumer<ExplorerProvider>(
      builder: (context, explorerProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...explorerProvider.events.map((event) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed('/event-details', arguments: event.id);
                  },
                  child: _buildEventCard(event, explorerProvider),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard(Event event, ExplorerProvider explorerProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(6),
            ),
            child: event.artworkPath != null && event.artworkPath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(event.artworkPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      event.imageUrl,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            event.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Date
          Text(
            '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),

          // Venue
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.venue.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    explorerProvider.toggleLikeEvent(event.id);
                  },
                  icon: Icon(
                    explorerProvider.isEventLiked(event.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 16,
                  ),
                  label: Text('${event.likes}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: explorerProvider.isEventLiked(event.id)
                        ? AppColors.accent
                        : AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    explorerProvider.toggleBookmarkEvent(event.id);
                  },
                  icon: Icon(
                    event.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 16,
                  ),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: event.isBookmarked
                        ? AppColors.accent
                        : AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsTab() {
    return Consumer<ExplorerProvider>(
      builder: (context, explorerProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Featured Artists',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...explorerProvider.artists.map((artist) {
                final isFollowing = explorerProvider.followedArtistIds.contains(
                  artist.id,
                );
                return GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed('/artist-profile', arguments: artist.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          artist.imageUrl,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artist.name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                artist.genre,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${artist.followers} followers',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            explorerProvider.toggleFollowArtist(artist.id);
                          },
                          icon: Icon(
                            isFollowing ? Icons.check : Icons.add,
                            size: 16,
                          ),
                          label: Text(isFollowing ? 'Following' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? AppColors.accent
                                : AppColors.divider,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalDashboard() {
    return Consumer<ExplorerProvider>(
      builder: (context, explorerProvider, _) {
        final bookmarkedEvents = explorerProvider.getBookmarkedEvents();
        final followedArtists = explorerProvider.getFollowedArtists();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.currentUser?.displayName ?? 'Explorer'}!',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your personalized event experience',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Bookmarked events section
              Text(
                'Saved Events (${bookmarkedEvents.length})',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (bookmarkedEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No saved events yet. Browse and bookmark events!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...bookmarkedEvents.map(
                  (event) => GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/event-details', arguments: event.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            event.imageUrl,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  event.venue.name,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Followed artists section
              Text(
                'Following (${followedArtists.length})',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (followedArtists.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No followed artists yet. Browse and follow your favorites!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: followedArtists
                      .map(
                        (artist) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/artist-profile',
                              arguments: artist.id,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  artist.imageUrl,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    artist.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}
