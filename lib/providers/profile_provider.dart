import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/profile_repository.dart';

enum ProfileStatus { idle, loading, success, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  UserProfileModel? profile;
  ProfileStatus status = ProfileStatus.idle;
  String? errorMessage;
  File? pendingAvatarFile;

  Future<void> load() async {
    status = ProfileStatus.loading;
    notifyListeners();
    profile = await _repo.fetchProfile();
    status = ProfileStatus.idle;
    notifyListeners();
  }

  void setPendingAvatar(File file) {
    pendingAvatarFile = file;
    notifyListeners();
  }

  String? validateName(String value) {
    if (value.trim().isEmpty) return 'Name cannot be empty';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  String? validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email cannot be empty';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  Future<bool> save({
    required String name,
    required String email,
    required String gender,
    DateTime? dob,
  }) async {
    status = ProfileStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final updated = (profile ??
              UserProfileModel(
                  name: '', email: '', phone: '', gender: 'Not specified'))
          .copyWith(
        name: name.trim(),
        email: email.trim(),
        gender: gender,
        dob: dob,
        avatarPath: pendingAvatarFile?.path,
      );
      profile = await _repo.updateProfile(updated);
      status = ProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      status = ProfileStatus.error;
      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
