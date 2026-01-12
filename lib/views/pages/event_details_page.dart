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
    return Consumer<ExplorerProvider>(
      builder: (context, explorerProvider, _) {
        final event = explorerProvider.getEventById(eventId);

        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event Not Found')),
            body: const Center(child: Text('Event not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Event Details'), elevation: 0),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image
                Container(
                  width: double.infinity,
                  height: 250,
                  color: AppColors.cardBg,
                  child: Center(
                    child: Text(
                      event.imageUrl,
                      style: const TextStyle(fontSize: 80),
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
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Venue info
                      _buildVenueSection(event.venue),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'About Event',
                        style: const TextStyle(
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
                      Text(
                        'Lineup',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildLineupList(
                        context,
                        event.lineup,
                        explorerProvider,
                      ),
                      const SizedBox(height: 24),

                      // Actions row
                      Row(
                        children: [
                          // Like button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                explorerProvider.toggleLikeEvent(eventId);
                              },
                              icon: Icon(
                                explorerProvider.isEventLiked(eventId)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text('${event.likes} Likes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    explorerProvider.isEventLiked(eventId)
                                    ? AppColors.accent
                                    : AppColors.divider,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Bookmark button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                explorerProvider.toggleBookmarkEvent(eventId);
                              },
                              icon: Icon(
                                event.isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              label: Text(
                                event.isBookmarked ? 'Bookmarked' : 'Bookmark',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: event.isBookmarked
                                    ? AppColors.accent
                                    : AppColors.divider,
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
                              const SnackBar(
                                content: Text('Opening tickets...'),
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
          ),
        );
      },
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
    ExplorerProvider explorerProvider,
  ) {
    return lineup.map((artist) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed('/artist-profile', arguments: artist.artistId);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(artist.imageUrl, style: const TextStyle(fontSize: 32)),
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
