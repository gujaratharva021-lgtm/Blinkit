import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/wishlist_item_model.dart';

class WishlistMockDataSource {
  final Dio _dio = Dio();
  List<WishlistItemModel>? _cache;

  bool simulateError = false;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 700));

  Future<List<WishlistItemModel>> _loadSeed() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/mock/wishlist.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<WishlistItemModel>> fetchWishlist() async {
    await _delay();
    if (simulateError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/wishlist'),
        error: 'Unable to reach server',
        type: DioExceptionType.connectionError,
      );
    }
    return _loadSeed();
  }

  Future<bool> removeFromWishlist(String id) async {
    await _delay();
    final list = await _loadSeed();
    list.removeWhere((item) => item.id == id);
    return true;
  }

  Future<bool> moveToCart(String id) async {
    await _delay();
    final list = await _loadSeed();
    list.removeWhere((item) => item.id == id);
    return true;
  }
}

