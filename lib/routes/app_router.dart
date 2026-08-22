import 'package:go_router/go_router.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/notification_preferences_screen.dart';
import '../screens/settings/account_privacy_screen.dart';
import '../screens/share/share_app_screen.dart';
import '../screens/about/about_us_screen.dart';

/// Route definitions for the new Profile-settings flow.
/// Not yet wired as the app's root router (the rest of the app still
/// uses Navigator/MaterialPageRoute) — share main.dart to complete the
/// full GoRouter migration.
class AppRoutes {
  static const editProfile = '/profile/edit';
  static const notificationPreferences = '/profile/notifications';
  static const accountPrivacy = '/profile/privacy';
  static const shareApp = '/profile/share';
  static const aboutUs = '/profile/about';
}

final List<GoRoute> profileRoutes = [
  GoRoute(
    path: AppRoutes.editProfile,
    builder: (context, state) => const EditProfileScreen(),
  ),
  GoRoute(
    path: AppRoutes.notificationPreferences,
    builder: (context, state) => const NotificationPreferencesScreen(),
  ),
  GoRoute(
    path: AppRoutes.accountPrivacy,
    builder: (context, state) => const AccountPrivacyScreen(),
  ),
  GoRoute(
    path: AppRoutes.shareApp,
    builder: (context, state) => const ShareAppScreen(),
  ),
  GoRoute(
    path: AppRoutes.aboutUs,
    builder: (context, state) => const AboutUsScreen(),
  ),
];
