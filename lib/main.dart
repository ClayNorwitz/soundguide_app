import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/constants/persona_config.dart';
import 'package:soundguide_app/providers/auth_provider.dart';
import 'package:soundguide_app/views/pages/landing_page.dart';
import 'package:soundguide_app/views/pages/goer_dashboard.dart';
import 'package:soundguide_app/views/pages/organiser_dashboard.dart';
import 'package:soundguide_app/views/pages/artist_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'SoundGuide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.cardBg,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        home: const LandingPage(),
        routes: {
          '/': (context) => const LandingPage(),
          '/goer-dashboard': (context) => const GoerDashboard(),
          '/organiser-dashboard': (context) => const OrganiserDashboard(),
          '/artist-dashboard': (context) => const ArtistDashboard(),
        },
      ),
    );
  }
}
