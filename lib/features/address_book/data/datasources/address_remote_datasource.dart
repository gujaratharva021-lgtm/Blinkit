import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/api_service.dart';
import '../models/address_model.dart';

/// Real datasource hitting the backend's /addresses endpoints (replaces
/// AddressMockDataSource, which never actually persisted anything).
class AddressRemoteDataSource {
  Future<Map<String, String>> _headers() async {
    final token = await ApiService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AddressModel>> fetchAddresses() async {
    final res = await http
        .get(Uri.parse('${ApiService.baseUrl}/addresses'), headers: await _headers())
        .timeout(const Duration(seconds: 20));
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load addresses');
    }
    final list = (data['addresses'] as List<dynamic>? ?? []);
    return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final res = await http
        .post(
          Uri.parse('${ApiService.baseUrl}/addresses'),
          headers: await _headers(),
          body: jsonEncode(address.toRequestJson()),
        )
        .timeout(const Duration(seconds: 20));
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(data['error'] ?? 'Failed to save address');
    }
    return AddressModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    final res = await http
        .put(
          Uri.parse('${ApiService.baseUrl}/addresses/${address.id}'),
          headers: await _headers(),
          body: jsonEncode(address.toRequestJson()),
        )
        .timeout(const Duration(seconds: 20));
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to update address');
    }
    return AddressModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> deleteAddress(String id) async {
    final res = await http
        .delete(Uri.parse('${ApiService.baseUrl}/addresses/$id'), headers: await _headers())
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200 && res.statusCode != 204) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Failed to delete address');
    }
    return true;
  }

  Future<bool> setDefaultAddress(String id) async {
    final res = await http
        .put(
          Uri.parse('${ApiService.baseUrl}/addresses/$id/default'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Failed to set default address');
    }
    return true;
  }
}
