# Run this script from the ROOT of your local "Blinkit" repo folder
# (the folder that contains the "lib" directory).
# It will overwrite the 3 fixed files with the corrected versions.

$ErrorActionPreference = "Stop"

if (-not (Test-Path "lib")) {
    Write-Host "ERROR: 'lib' folder not found. Run this script from the Blinkit repo root." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# 1) lib/features/gst_details/data/datasources/gst_mock_datasource.dart
#    Fix: GST getting added twice
# ---------------------------------------------------------------------------
$gstPath = "lib/features/gst_details/data/datasources/gst_mock_datasource.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $gstPath) | Out-Null
@'
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/gst_model.dart';

class GstMockDataSource {
  final Dio _dio = Dio();
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
'@ | Set-Content -Path $gstPath -Encoding UTF8
Write-Host "Updated $gstPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2) lib/screens/profile_screen.dart
#    Fix: Profile not updating after Save changes
# ---------------------------------------------------------------------------
$profilePath = "lib/screens/profile_screen.dart"
@'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import 'login_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'settings/notification_preferences_screen.dart';
import 'notifications/notification_list_screen.dart';
import 'settings/account_privacy_screen.dart';
import 'share/share_app_screen.dart';
import 'orders/order_list_screen.dart';
import 'order_screen.dart';
import 'wallet/wallet_screen.dart';
import 'support/support_home_screen.dart';
import 'about/about_us_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/gst_details/presentation/screens/gst_list_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';

const Color kGreen = Color(0xFF0C831F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure we have the latest saved profile (e.g. after returning from
    // Edit profile on a previous visit, or first load in this session).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final name = (profile?.name.trim().isNotEmpty ?? false) ? profile!.name : 'User';
    final phone = profile?.phone ?? '';
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      },
      child: Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(scheme, name, phone),
              const SizedBox(height: 16),
              _buildQuickActions(scheme),
              const SizedBox(height: 16),
              _buildSettingsCard(settings, scheme),
              const SizedBox(height: 20),
              _buildSectionLabel('Your information', scheme),
              _buildSectionCard(scheme, [
                _tile(Icons.favorite_border, 'Your wishlist', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()));
                }, scheme),
                _tile(Icons.description_outlined, 'GST details', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GstListScreen()));
                }, scheme, isLast: true),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Payment and coupons', scheme),
              _buildSectionCard(scheme, [
                _tile(Icons.account_balance_wallet_outlined, 'GoFresh Money', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()));
                }, scheme),
                _tile(Icons.credit_card_outlined, 'Payment settings',
                    () => _showComingSoon('Payment settings'), scheme, isLast: true),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Other information', scheme),
              _buildSectionCard(scheme, [
                _tile(Icons.ios_share_outlined, 'Share the app', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ShareAppScreen()));
                }, scheme),
                _tile(Icons.info_outline, 'About us', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                }, scheme),
                _tile(Icons.lock_outline, 'Account privacy', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountPrivacyScreen()));
                }, scheme),
                _tile(Icons.notifications_active_outlined,
                    'Notifications', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationListScreen()));
                }, scheme),
                _tile(Icons.notifications_none_outlined,
                    'Notification preferences', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationPreferencesScreen()));
                }, scheme),
                _tile(Icons.logout, 'Log out', _confirmLogout, scheme, isLast: true),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()));
              break;
            case 2:
              break;
          }
        },
        selectedItemColor: kGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader(ColorScheme scheme, String name, String phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.primaryContainer, scheme.surface],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: scheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
            child: CircleAvatar(
              radius: 42,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                    fontSize: 34, fontWeight: FontWeight.bold, color: kGreen),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Your account',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: scheme.onSurface)),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('+91 $phone',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: scheme.onSurface.withOpacity(0.6))),
          ],
        ],
      ),
    );
  }

  // ---------- Quick actions ----------

  Widget _buildQuickActions(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(Icons.shopping_bag_outlined, 'Your orders', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrderScreen()));
            }, scheme),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(Icons.account_balance_wallet_outlined,
                'GoFresh Money', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()));
            }, scheme),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(Icons.headset_mic_outlined, 'Need help?', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SupportHomeScreen()));
            }, scheme),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap, ColorScheme scheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: kGreen, size: 24),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          ],
        ),
      ),
    );
  }

  // ---------- Settings ----------

  Widget _buildSettingsCard(SettingsProvider settings, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SwitchListTile(
              value: settings.hideSensitive,
              activeColor: kGreen,
              onChanged: (val) {
                context.read<SettingsProvider>().setHideSensitive(val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val
                        ? 'Sensitive items hidden'
                        : 'Sensitive items visible'),
                    backgroundColor: kGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              secondary: Icon(Icons.visibility_off_outlined, color: scheme.onSurface),
              title: Text('Hide sensitive items',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface)),
              subtitle: Text('Hide sensitive products from recommendations and search',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: scheme.onSurface.withOpacity(0.6))),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Generic section helpers ----------

  Widget _buildSectionLabel(String title, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: scheme.onSurface)),
      ),
    );
  }

  Widget _buildSectionCard(ColorScheme scheme, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: tiles),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, ColorScheme scheme,
      {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: scheme.onSurface),
          title: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          trailing: Icon(Icons.chevron_right, color: scheme.onSurface.withOpacity(0.5)),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(height: 1, indent: 16, endIndent: 16, color: scheme.outlineVariant),
      ],
    );
  }

  // ---------- Actions ----------

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon',
            style: GoogleFonts.poppins()),
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
              onPressed: () async {
                await ApiService.clearToken();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  context.read<SettingsProvider>().clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }
}
'@ | Set-Content -Path $profilePath -Encoding UTF8
Write-Host "Updated $profilePath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3) lib/services/api_service.dart
#    Fix: Cancel button not working (POST -> PUT for /orders/:id/cancel)
# ---------------------------------------------------------------------------
$apiPath = "lib/services/api_service.dart"
@'
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://ecommerce-backend-dd4u.onrender.com/api/v1';

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
    List<dynamic> all = [];
    int page = 1;
    while (true) {
      String url = '$baseUrl/products/?limit=100&page=$page';
      if (category != null) url += '&category=$category';
      final response = await http.get(Uri.parse(url), headers: headers);
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
      Uri.parse('$baseUrl/cart'),
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCartItem(int itemId, int quantity) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$itemId'),
      headers: headers,
      body: jsonEncode({'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeCartItem(int itemId) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$itemId'),
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

  static Future<List<dynamic>> getOrders({int page = 1, int limit = 100}) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders?page=$page&limit=$limit'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['orders'] ?? [];
  }

  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> address) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/addresses'),
      headers: headers,
      body: jsonEncode(address),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkout({required int addressId, String paymentMethod = 'online'}) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/checkout'),
      headers: headers,
      body: jsonEncode({'address_id': addressId, 'payment_method': paymentMethod}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createPaymentOrder(int orderId) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment'),
      headers: headers,
    );
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

  static Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/tracking'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/cancel'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw Exception((data['error'] ?? 'Could not cancel order').toString());
    }
    return data;
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
    );
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
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw Exception((data['error'] ?? 'Could not load return requests').toString());
    }
    return data['return_requests'] ?? [];
  }
}
'@ | Set-Content -Path $apiPath -Encoding UTF8
Write-Host "Updated $apiPath" -ForegroundColor Green

Write-Host ""
Write-Host "All 3 files updated successfully." -ForegroundColor Cyan
Write-Host "Run 'flutter pub get' and rebuild the app to test." -ForegroundColor Cyan
