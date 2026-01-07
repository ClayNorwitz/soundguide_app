import 'package:flutter/material.dart';
import 'app_colors.dart';

enum UserType { goer, organiser, performer }

class PersonaConfig {
  static final Map<UserType, PersonaInfo> config = {
    UserType.goer: PersonaInfo(
      id: 'goer',
      title: 'Explore',
      subtitle: 'Discover Events',
      description: 'Find and attend unforgettable events',
      gradient: AppColors.explorerGradient,
      icon: Icons.map_outlined,
      route: '/goer-dashboard',
    ),
    UserType.organiser: PersonaInfo(
      id: 'organiser',
      title: 'Host',
      subtitle: 'Organize Events',
      description: 'Create and manage your events',
      gradient: AppColors.hostGradient,
      icon: Icons.calendar_month_outlined,
      route: '/organiser-dashboard',
    ),
    UserType.performer: PersonaInfo(
      id: 'performer',
      title: 'Perform',
      subtitle: 'Share Your Art',
      description: 'Showcase your talent to the world',
      gradient: AppColors.performerGradient,
      icon: Icons.music_note_outlined,
      route: '/artist-dashboard',
    ),
  };

  static PersonaInfo getInfo(UserType type) => config[type]!;
  static String getBackendValue(UserType type) => config[type]!.id;

  static Color getAccentColor(UserType type) {
    switch (type) {
      case UserType.goer:
        return AppColors.explorerAccent;
      case UserType.organiser:
        return AppColors.hostAccent;
      case UserType.performer:
        return AppColors.performerAccent;
    }
  }
}

class PersonaInfo {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final LinearGradient gradient;
  final IconData icon;
  final String route;

  PersonaInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.icon,
    required this.route,
  });
}
