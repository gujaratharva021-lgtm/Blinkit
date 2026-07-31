import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/address_model.dart';

/// Mock datasource. A [Dio] instance is kept here so the class shape matches
/// a real network datasource â€” swap the body of each method for an actual
/// `dio.get(...)` / `dio.post(...)` call once the backend is ready.
class AddressMockDataSource {
  final Dio _dio = Dio();
  List<AddressModel>? _cache;

  /// Set to true from a debug menu to preview the error state.
  bool simulateError = false;

  Future<void> _simulateNetworkDelay() =>
      Future.delayed(const Duration(milliseconds: 700));

  Future<List<AddressModel>> _loadSeed() async {
    if (_cache != null) return _cache!;
    final raw =
        await rootBundle.loadString('assets/mock/addresses.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<AddressModel>> fetchAddresses() async {
    await _simulateNetworkDelay();
    if (simulateError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/addresses'),
        error: 'Unable to reach server',
        type: DioExceptionType.connectionError,
      );
    }
    return _loadSeed();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    await _simulateNetworkDelay();
    final list = await _loadSeed();
    list.add(address);
    return address;
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    await _simulateNetworkDelay();
    final list = await _loadSeed();
    final index = list.indexWhere((a) => a.id == address.id);
    if (index != -1) list[index] = address;
    return address;
  }

  Future<bool> deleteAddress(String id) async {
    await _simulateNetworkDelay();
    final list = await _loadSeed();
    list.removeWhere((a) => a.id == id);
    return true;
  }

  Future<bool> setDefaultAddress(String id) async {
    await _simulateNetworkDelay();
    final list = await _loadSeed();
    for (var i = 0; i < list.length; i++) {
      list[i] = AddressModel.fromEntity(
        list[i].copyWith(isDefault: list[i].id == id),
      );
    }
    return true;
  }
}

