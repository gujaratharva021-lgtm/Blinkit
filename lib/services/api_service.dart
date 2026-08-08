import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // L-03: no longer hard-coded to production. Override at build/run time with:
  //   flutter run --dart-define=API_BASE_URL=https://your-env.example.com/api/v1
  // Falls back to the production URL only when nothing is supplied.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ecommerce-backend-dd4u.onrender.com/api/v1',
  );

  static const Duration _timeout = Duration(seconds: 30);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> sendOTP(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(_timeout);
      // L-04: never log the response body here - in test-mode deployments it
      // contains the raw OTP, and printing it puts the OTP straight into the
      // device log.
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String phone, String otp, {String? name}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
        if (name != null) 'name': name,
      }),
    ).timeout(_timeout);
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      await saveToken(data['token']);
    }
    return data;
  }

  static Future<List<dynamic>> getProducts({String? category}) async {
    final headers = await getHeaders();
    List<dynamic> all = [];
    int page = 1;
    while (true) {
      String url = '$baseUrl/products/?limit=100&page=$page';
      if (category != null) {
        url += '&category_id=${Uri.encodeQueryComponent(category)}';
      }
      final response = await http.get(Uri.parse(url), headers: headers).timeout(_timeout);
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['products'] ?? [];
      all.addAll(items);
      final totalPages = (data['total_pages'] ?? 1) as int;
      if (page >= totalPages || items.isEmpty) break;
      page++;
    }
    return all;
  }

  static Future<List<dynamic>> searchProducts(String query) async {
    final headers = await getHeaders();
    // L-05: URL-encode the query so &, #, +, spaces, etc. don't corrupt the URL.
    final response = await http.get(
      Uri.parse('$baseUrl/products/search?q=${Uri.encodeQueryComponent(query)}'),
      headers: headers,
    ).timeout(_timeout);
    final data = jsonDecode(response.body);
    return data['products'] ?? [];
  }

  static Future<Map<String, dynamic>> getCart() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addToCart(int productId, int quantity) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCartItem(int itemId, int quantity) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$itemId'),
      headers: headers,
      body: jsonEncode({'quantity': quantity}),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeCartItem(int itemId) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$itemId'),
      headers: headers,
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> placeOrder(String address) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/place'),
      headers: headers,
      body: jsonEncode({'address': address}),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getOrders({int page = 1, int limit = 100}) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders?page=$page&limit=$limit'),
      headers: headers,
    ).timeout(_timeout);
    final data = jsonDecode(response.body);
    return data['orders'] ?? [];
  }

  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> address) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/addresses'),
      headers: headers,
      body: jsonEncode(address),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  // L-07: checkout() can now forward coupon_code and use_wallet, matching
  // what the backend and the web checkout already support. Mobile customers
  // could never redeem a coupon or spend their wallet before this.
  static Future<Map<String, dynamic>> checkout({
    required int addressId,
    String paymentMethod = 'online',
    String? couponCode,
    bool useWallet = false,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/checkout'),
      headers: headers,
      body: jsonEncode({
        'address_id': addressId,
        'payment_method': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        'use_wallet': useWallet,
      }),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPaymentOrder(int orderId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment'),
      headers: headers,
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required int orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment/verify'),
      headers: headers,
      body: jsonEncode({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      }),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> directPlaceOrder(
      String address, List<Map<String, dynamic>> items) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/direct'),
      headers: headers,
      body: jsonEncode({'address': address, 'items': items}),
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/tracking'),
      headers: headers,
    ).timeout(_timeout);
    return jsonDecode(response.body);
  }

  /// items: list of {"order_item_id": int, "quantity": int}
  static Future<Map<String, dynamic>> requestReturn({
    required int orderId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/return'),
      headers: headers,
      body: jsonEncode({'reason': reason, 'items': items}),
    ).timeout(_timeout);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw Exception((data['error'] ?? 'Could not submit return request').toString());
    }
    return data;
  }

  static Future<List<dynamic>> getMyReturns() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/returns'),
      headers: headers,
    ).timeout(_timeout);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw Exception((data['error'] ?? 'Could not load return requests').toString());
    }
    return data['return_requests'] ?? [];
  }
}
