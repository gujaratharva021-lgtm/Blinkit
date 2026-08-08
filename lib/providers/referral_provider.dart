import 'package:flutter/material.dart';
import '../data/models/referral_model.dart';
import '../data/repositories/referral_repository.dart';

class ReferralProvider extends ChangeNotifier {
  final ReferralRepository _repo = ReferralRepository();
  ReferralModel? referral;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    referral = await _repo.fetchReferral();
    loading = false;
    notifyListeners();
  }
}
