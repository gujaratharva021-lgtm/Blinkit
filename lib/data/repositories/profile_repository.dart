import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

/// Mock repository — reads seed data from local JSON, persists edits to
/// SharedPreferences. Replace the body of each method with real Dio calls
/// (the `_dio` client is already wired) once a backend endpoint exists.
class ProfileRepository {
  static const _prefsKey = 'user_profile_json';
  static const _loginPhoneKey = 'user_phone'; // set by OtpScreen on successful login

  Future<UserProfileModel> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final loginPhone = prefs.getString(_loginPhoneKey);
    final saved = prefs.getString(_prefsKey);

    UserProfileModel profile;
    if (saved != null) {
      profile = UserProfileModel.fromJson(jsonDecode(saved));
    } else {
      final raw = await rootBundle.loadString('assets/data/user_profile.json');
      profile = UserProfileModel.fromJson(jsonDecode(raw));
    }

    // Keep the profile's phone number in sync with the number the user
    // actually logged in with, so the account always shows the real number.
    if (loginPhone != null &&
        loginPhone.isNotEmpty &&
        profile.phone != loginPhone) {
      profile = profile.copyWith(phone: loginPhone);
      await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
    }

    return profile;
  }

  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
    return profile;
  }
}
