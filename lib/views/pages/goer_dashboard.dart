import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/models/event_models.dart';
import 'package:soundguide_app/providers/auth_provider.dart';
import 'package:soundguide_app/providers/explorer_provider.dart';
import 'package:soundguide_app/views/pages/account_settings_page.dart';

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
          const Divider(color: AppColors.divider, height: 32),

          // NEW ACCOUNT SETTINGS TAB
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.accent),
            title: const Text(
              'Account Settings',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsPage(),
                ),
              );
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

  // --- TAB 1: EVENTS (Using StreamBuilder) ---
  Widget _buildEventsTab() {
    final provider = Provider.of<ExplorerProvider>(context, listen: false);

    return StreamBuilder<List<Event>>(
      stream: provider.approvedEventsStream, // LISTENING TO FIREBASE
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming events found.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

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
              ...events.map((event) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed('/event-details', arguments: event.id);
                  },
                  child: _buildEventCard(
                    event,
                  ), // No longer passing provider, we use context read inside
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: ARTISTS ---
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

  // --- TAB 3: PERSONAL DASHBOARD ---
  Widget _buildPersonalDashboard() {
    final provider = Provider.of<ExplorerProvider>(context);
    final followedArtists = provider.getFollowedArtists();

    return StreamBuilder<List<Event>>(
      stream: provider.approvedEventsStream,
      builder: (context, snapshot) {
        // We get ALL events, then filter for bookmarks locally
        final allEvents = snapshot.data ?? [];
        final bookmarkedEvents = allEvents
            .where((e) => provider.isEventBookmarked(e.id))
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
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

              // Bookmarked Events
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
                          // Small Thumbnail
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: AppColors.divider,
                            ),
                            child: (event.imageUrl?.isNotEmpty ?? false)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      event.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                  ),
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

              // Followed Artists
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
                    'No followed artists yet.',
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

  // --- REUSABLE EVENT CARD ---
  Widget _buildEventCard(Event event) {
    // We access the provider inside here to get like/bookmark status
    final provider = Provider.of<ExplorerProvider>(context);
    final isLiked = provider.isEventLiked(event.id);
    final isBookmarked = provider.isEventBookmarked(event.id);

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
          // Event Image (Network aware)
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(6),
            ),
            child: (event.imageUrl?.isNotEmpty ?? false)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.toggleLikeEvent(event.id),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                  ),
                  label: Text('${event.likes}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLiked
                        ? AppColors.accent
                        : AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.toggleBookmarkEvent(event.id),
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 16,
                  ),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBookmarked
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
}
