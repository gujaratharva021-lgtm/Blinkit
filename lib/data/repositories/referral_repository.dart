import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/referral_model.dart';

class ReferralRepository {
  Future<ReferralModel> fetchReferral() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final raw = await rootBundle.loadString('assets/data/referral.json');
    return ReferralModel.fromJson(jsonDecode(raw));
  }
}
