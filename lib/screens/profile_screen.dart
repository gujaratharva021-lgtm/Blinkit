import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'order_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Profile',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + kToolbarHeight + 8, 24, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0C831F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0C831F)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_name,
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  if (_phone.isNotEmpty)
                    Text('+91 $_phone',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Orders Section
            _buildSectionTitle('My Orders'),
            _buildMenuItem(
                Icons.shopping_bag_outlined, 'My Orders', 'Track your orders',
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OrderScreen()));
                }),

            const SizedBox(height: 12),

            // Account Section
            _buildSectionTitle('Account'),
            _buildMenuItem(
                Icons.location_on_outlined,
                'Saved Addresses',
                'Manage delivery addresses', () {
              _showAddressDialog();
            }),
            _buildMenuItem(Icons.payment_outlined, 'Payment Methods',
                'UPI, Cards & Wallets', () {
                  _showComingSoon('Payment Methods');
                }),
            _buildMenuItem(
                Icons.person_outline, 'Edit Profile', 'Update your details',
                    () {
                  _showEditProfile();
                }),

            const SizedBox(height: 12),

            // Support Section
            _buildSectionTitle('Support'),
            _buildMenuItem(
                Icons.help_outline, 'Help & Support', 'FAQs and contact us',
                    () {
                  _showComingSoon('Help & Support');
                }),
            _buildMenuItem(Icons.star_outline, 'Rate the App',
                'Share your feedback', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thanks for rating! ⭐',
                          style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }),
            _buildMenuItem(
                Icons.info_outline, 'About blinkit', 'Version 1.0.0', () {
              showAboutDialog(
                context: context,
                applicationName: 'Mepto',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Mepto. All rights reserved.',
              );
            }),

            const SizedBox(height: 12),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: Text('Logout',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                        content: Text('Are you sure you want to logout?',
                            style: GoogleFonts.poppins()),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey))),
                          ElevatedButton(
                              onPressed: () async {
                                await ApiService.clearToken();
                                final prefs =
                                await SharedPreferences.getInstance();
                                await prefs.clear();
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                        (route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10))),
                              child: Text('Logout',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white))),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text('Logout',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon! 🚀',
            style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF0C831F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddressDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Address',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your address',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          style: GoogleFonts.poppins(),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('saved_address', controller.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Address saved! ✅',
                            style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C831F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Save',
                  style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }

  void _showEditProfile() {
    final nameController = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_name', nameController.text);
                  setState(() => _name = nameController.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated! ✅',
                            style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C831F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Save',
                  style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 6)
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0C831F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0C831F), size: 22),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        trailing:
        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}