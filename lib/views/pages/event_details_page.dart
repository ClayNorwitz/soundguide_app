import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/models/event_models.dart';
import 'package:soundguide_app/providers/explorer_provider.dart';

class EventDetailsPage extends StatelessWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // We listen to the Provider only for actions (likes/bookmarks),
    // but we use a StreamBuilder for the Event data itself.
    final explorerProvider = Provider.of<ExplorerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      // AppBar needs to be inside StreamBuilder or transparent if we want the image to go behind it.
      // For simplicity, we keep the standard Scaffold structure.
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: AppColors.cardBg,
        elevation: 0,
      ),
      body: StreamBuilder<Event>(
        stream: explorerProvider.getEventStream(eventId),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          // 2. Error or Not Found
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Event not found or deleted',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // 3. Data Loaded
          final event = snapshot.data!;
          final isLiked = explorerProvider.isEventLiked(event.id);
          final isBookmarked = explorerProvider.isEventBookmarked(event.id);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image
                Container(
                  width: double.infinity,
                  height: 250,
                  color: AppColors.cardBg,
                  child: (event.imageUrl?.isNotEmpty ?? false)
                      ? Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                ),
                              ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date & Time
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event.dateTime.day} ${_getMonth(event.dateTime.month)} ${event.dateTime.year}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Venue info
                      _buildVenueSection(event.venue),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'About Event',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lineup
                      if (event.lineup.isNotEmpty) ...[
                        const Text(
                          'Lineup',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildLineupList(context, event.lineup),
                        const SizedBox(height: 24),
                      ],

                      // Actions row (Likes & Bookmarks)
                      Row(
                        children: [
                          // Like button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  explorerProvider.toggleLikeEvent(event.id),
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text('${event.likes} Likes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLiked
                                    ? AppColors.accent
                                    : AppColors.divider,
                                foregroundColor: isLiked
                                    ? AppColors.primary
                                    : AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Bookmark button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => explorerProvider
                                  .toggleBookmarkEvent(event.id),
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              label: Text(
                                isBookmarked ? 'Bookmarked' : 'Bookmark',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBookmarked
                                    ? AppColors.accent
                                    : AppColors.divider,
                                foregroundColor: isBookmarked
                                    ? AppColors.primary
                                    : AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Get tickets button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening ${event.ticketUrl}...'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Get Tickets - R${event.ticketPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueSection(Venue venue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            venue.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  venue.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people, color: AppColors.accent, size: 16),
              const SizedBox(width: 8),
              Text(
                'Capacity: ${venue.capacity} people',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLineupList(
    BuildContext context,
    List<LineupArtist> lineup,
  ) {
    return lineup.map((artist) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            // Navigate to artist profile if needed
            // Navigator.of(context).pushNamed('/artist-profile', arguments: artist.artistId);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.divider,
                  backgroundImage: artist.imageUrl.isNotEmpty
                      ? NetworkImage(artist.imageUrl)
                      : null,
                  child: artist.imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${artist.startTime} - ${artist.endTime}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.accent,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
