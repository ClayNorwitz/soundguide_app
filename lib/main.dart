import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/providers/auth_provider.dart';
import 'package:soundguide_app/providers/explorer_provider.dart';
import 'package:soundguide_app/views/pages/splash_page.dart';
import 'package:soundguide_app/views/pages/landing_page.dart';
import 'package:soundguide_app/views/pages/goer_dashboard.dart';
import 'package:soundguide_app/views/pages/organiser_dashboard.dart';
import 'package:soundguide_app/views/pages/artist_dashboard.dart';
import 'package:soundguide_app/views/pages/event_details_page.dart';
import 'package:soundguide_app/views/pages/artist_profile_page.dart';
import 'package:soundguide_app/views/pages/account_settings_page.dart';
import 'package:soundguide_app/views/pages/add_event_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExplorerProvider()),
      ],
      child: MaterialApp(
        title: 'SoundGuide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // ...
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
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.accent,
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
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/event-details') {
            final eventId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => EventDetailsPage(eventId: eventId),
            );
          } else if (settings.name == '/artist-profile') {
            final artistId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ArtistProfilePage(artistId: artistId),
            );
          }
          return null;
        },
        routes: {
          '/landing': (context) => const LandingPage(),
          '/goer-dashboard': (context) => const GoerDashboard(),
          '/organiser-dashboard': (context) => const OrganiserDashboard(),
          '/artist-dashboard': (context) => const ArtistDashboard(),
          '/account-settings': (context) => const AccountSettingsPage(),
          '/add-event': (context) => const AddEventPage(),
        },
      ),
    );
  }
}
