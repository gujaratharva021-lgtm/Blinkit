import 'dart:convert';
import 'package:dio/dio.dart' show DioException, DioExceptionType, RequestOptions;
import 'package:flutter/services.dart' show rootBundle;
import '../models/gst_model.dart';

class GstMockDataSource {
  List<GstModel>? _cache;

  bool simulateError = false;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 700));

  Future<List<GstModel>> _loadSeed() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/mock/gst_details.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache =
        list.map((e) => GstModel.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  Future<List<GstModel>> fetchGstDetails() async {
    await _delay();
    if (simulateError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/gst-details'),
        error: 'Unable to reach server',
        type: DioExceptionType.connectionError,
      );
    }
    // Return a copy, not the live cache reference -- otherwise the caller's
    // list and our internal cache are the same object in memory, so later
    // mutating the cache in addGst() silently mutates the caller's list too.
    final seed = await _loadSeed();
    return List<GstModel>.from(seed);
  }

  Future<GstModel> addGst(GstModel gst) async {
    await _delay();
    final list = await _loadSeed();
    list.add(gst);
    return gst;
  }

  Future<GstModel> updateGst(GstModel gst) async {
    await _delay();
    final list = await _loadSeed();
    final index = list.indexWhere((g) => g.id == gst.id);
    if (index != -1) list[index] = gst;
    return gst;
  }

  Future<bool> deleteGst(String id) async {
    await _delay();
    final list = await _loadSeed();
    list.removeWhere((g) => g.id == id);
    return true;
  }
}
