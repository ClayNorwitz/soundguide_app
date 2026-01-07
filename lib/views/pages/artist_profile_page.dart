import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/providers/explorer_provider.dart';

class ArtistProfilePage extends StatelessWidget {
  final String artistId;

  const ArtistProfilePage({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorerProvider>(
      builder: (context, explorerProvider, _) {
        final artist = explorerProvider.getArtistById(artistId);

        if (artist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Artist Not Found')),
            body: const Center(child: Text('Artist not found')),
          );
        }

        final isFollowing = explorerProvider.followedArtistIds.contains(
          artistId,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Artist Profile'), elevation: 0),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artist avatar
                Container(
                  width: double.infinity,
                  height: 250,
                  color: AppColors.cardBg,
                  child: Center(
                    child: Text(
                      artist.imageUrl,
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artist name
                      Text(
                        artist.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Genre
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          artist.genre,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Followers
                      Row(
                        children: [
                          const Icon(Icons.people, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            '${artist.followers} followers',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      Text(
                        'About',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artist.bio,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Social links
                      if (artist.socialLinks.isNotEmpty) ...[
                        Text(
                          'Follow',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: artist.socialLinks
                              .map(
                                (link) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Opening $link...'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.link),
                                    label: const Text('Social'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.accent,
                                      side: const BorderSide(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Follow button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            explorerProvider.toggleFollowArtist(artistId);
                          },
                          icon: Icon(isFollowing ? Icons.check : Icons.add),
                          label: Text(
                            isFollowing ? 'Following' : 'Follow Artist',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? AppColors.accent
                                : AppColors.divider,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
}
