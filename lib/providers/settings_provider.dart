import 'package:flutter/material.dart';
import '../data/models/notification_prefs_model.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  bool hideSensitive = false;
  NotificationPrefsModel notificationPrefs = NotificationPrefsModel(
    orders: true,
    offers: true,
    wallet: true,
    recommendations: false,
    updates: true,
  );

  Future<void> load() async {
    hideSensitive = await _repo.fetchHideSensitive();
    notificationPrefs = await _repo.fetchNotificationPrefs();
    notifyListeners();
  }

  Future<void> setHideSensitive(bool value) async {
    hideSensitive = value;
    notifyListeners();
    await _repo.saveHideSensitive(value);
  }

  Future<void> updateNotificationPref(String key, bool value) async {
    notificationPrefs = NotificationPrefsModel(
      orders: key == 'orders' ? value : notificationPrefs.orders,
      offers: key == 'offers' ? value : notificationPrefs.offers,
      wallet: key == 'wallet' ? value : notificationPrefs.wallet,
      recommendations:
          key == 'recommendations' ? value : notificationPrefs.recommendations,
      updates: key == 'updates' ? value : notificationPrefs.updates,
    );
    notifyListeners();
    await _repo.saveNotificationPrefs(notificationPrefs);
  }

  /// Clears in-memory provider state on logout.
  void clear() {
    hideSensitive = false;
    notificationPrefs = NotificationPrefsModel(
      orders: true,
      offers: true,
      wallet: true,
      recommendations: false,
      updates: true,
    );
    notifyListeners();
  }
}
