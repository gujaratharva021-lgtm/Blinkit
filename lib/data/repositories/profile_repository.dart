import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

/// Mock repository — reads seed data from local JSON, persists edits to
/// SharedPreferences. Replace the body of each method with real Dio calls
/// (the `_dio` client is already wired) once a backend endpoint exists.
class ProfileRepository {
  static const _prefsKey = 'user_profile_json';

  Future<UserProfileModel> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      return UserProfileModel.fromJson(jsonDecode(saved));
    }
    final raw = await rootBundle.loadString('assets/data/user_profile.json');
    return UserProfileModel.fromJson(jsonDecode(raw));
  }

  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
    return profile;
  }
}
