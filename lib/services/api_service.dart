import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://13.233.160.70:8081/api/v1';

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
      ).timeout(const Duration(seconds: 30));
      print('SendOTP status: ${response.statusCode}');
      print('SendOTP body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('SendOTP Error: $e');
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
    );
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      await saveToken(data['token']);
    }
    return data;
  }

  static Future<List<dynamic>> getProducts({String? category}) async {
    final headers = await getHeaders();
    String url = '$baseUrl/products/';
    if (category != null) url += '?category=$category';
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = jsonDecode(response.body);
    return data['products'] ?? [];
  }

  static Future<List<dynamic>> searchProducts(String query) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/products/search?q=$query'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['products'] ?? [];
  }

  static Future<Map<String, dynamic>> getCart() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addToCart(int productId, int quantity) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeFromCart(int productId) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$productId'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> placeOrder(String address) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/place'),
      headers: headers,
      body: jsonEncode({'address': address}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getOrders() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['orders'] ?? [];
  }

  static Future<Map<String, dynamic>> createPaymentOrder(int amount) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-order'),
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String address,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/payment/verify'),
      headers: headers,
      body: jsonEncode({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'address': address,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> directPlaceOrder(
      String address, List<Map<String, dynamic>> items) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/direct'),
      headers: headers,
      body: jsonEncode({'address': address, 'items': items}),
    );
    return jsonDecode(response.body);
  }
}