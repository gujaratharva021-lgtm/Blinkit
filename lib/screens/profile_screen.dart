import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../core/theme/theme_provider.dart';
import '../providers/settings_provider.dart';
import 'login_screen.dart';
import 'order_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'settings/notification_preferences_screen.dart';
import 'settings/account_privacy_screen.dart';
import 'share/share_app_screen.dart';
import 'about/about_us_screen.dart';

const Color kGreen = Color(0xFF0C831F);
const Color kBg = Color(0xFFF5F5F7);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _phone = prefs.getString('user_phone') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildBirthdayBanner(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildSettingsCard(settings, themeProvider),
              const SizedBox(height: 20),
              _buildSectionLabel('Your information'),
              _buildSectionCard([
                _tile(Icons.menu_book_outlined, 'Address book', _showAddressDialog),
                _tile(Icons.favorite_border, 'Your wishlist',
                    () => _showComingSoon('Wishlist')),
                _tile(Icons.description_outlined, 'GST details',
                    () => _showComingSoon('GST details')),
                _tile(Icons.card_giftcard_outlined, 'E-gift cards',
                    () => _showComingSoon('E-gift cards')),
                _tile(Icons.receipt_long_outlined, 'Your prescriptions',
                    () => _showComingSoon('Prescriptions'),
                    isLast: true),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Payment and coupons'),
              _buildSectionCard([
                _tile(Icons.account_balance_wallet_outlined, 'GoFresh Money',
                    () => _showComingSoon('GoFresh Money')),
                _tile(Icons.credit_card_outlined, 'Payment settings',
                    () => _showComingSoon('Payment settings')),
                _tile(Icons.redeem_outlined, 'Claim gift card',
                    () => _showComingSoon('Claim gift card')),
                _tile(Icons.card_membership_outlined, 'Your collected rewards',
                    () => _showComingSoon('Rewards'),
                    isLast: true),
              ]),
              const SizedBox(height: 20),
              _buildSectionLabel('Other information'),
              _buildSectionCard([
                _tile(Icons.ios_share_outlined, 'Share the app', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ShareAppScreen()));
                }),
                _tile(Icons.info_outline, 'About us', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                }),
                _tile(Icons.lock_outline, 'Account privacy', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountPrivacyScreen()));
                }),
                _tile(Icons.notifications_none_outlined,
                    'Notification preferences', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationPreferencesScreen()));
                }),
                _tile(Icons.logout, 'Log out', _confirmLogout, isLast: true),
              ]),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F6E4), kBg],
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
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
              backgroundColor: Colors.white,
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                    fontSize: 34, fontWeight: FontWeight.bold, color: kGreen),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Your account',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (_phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('+91 $_phone',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          ],
        ],
      ),
    );
  }

  Widget _buildBirthdayBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFAEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add your birthday',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showComingSoon('Birthday'),
                    child: Row(
                      children: [
                        Text('Enter details',
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600, color: kGreen)),
                        const Icon(Icons.chevron_right, size: 16, color: kGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.cake_outlined, size: 40, color: kGreen),
          ],
        ),
      ),
    );
  }

  // ---------- Quick actions ----------

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(Icons.shopping_bag_outlined, 'Your orders', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrderScreen()));
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(Icons.account_balance_wallet_outlined,
                'GoFresh Money', () => _showComingSoon('GoFresh Money')),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickAction(Icons.headset_mic_outlined, 'Need help?',
                () => _showComingSoon('Help & Support')),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
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
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ---------- Settings ----------

  Widget _buildSettingsCard(SettingsProvider settings, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined, color: Colors.black87),
              title: Text('Appearance',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: InkWell(
                onTap: () {
                  final next = themeProvider.mode == ThemeMode.light
                      ? ThemeMode.dark
                      : themeProvider.mode == ThemeMode.dark
                          ? ThemeMode.system
                          : ThemeMode.light;
                  themeProvider.setMode(next);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(themeProvider.label.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w700, color: kGreen)),
                    const Icon(Icons.keyboard_arrow_down, color: kGreen),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
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
              secondary: const Icon(Icons.visibility_off_outlined, color: Colors.black87),
              title: Text('Hide sensitive items',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('Hide sensitive products from recommendations and search',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Generic section helpers ----------

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: tiles),
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
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

  void _showAddressDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add address', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your address',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: GoogleFonts.poppins(),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('saved_address', controller.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Address saved', style: GoogleFonts.poppins()),
                        backgroundColor: kGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Save', style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }
}
