import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/app_info_model.dart';

class AppInfoRepository {
  Future<AppInfoModel> fetchAppInfo() async {
    final raw = await rootBundle.loadString('assets/data/app_info.json');
    return AppInfoModel.fromJson(jsonDecode(raw));
  }
}
