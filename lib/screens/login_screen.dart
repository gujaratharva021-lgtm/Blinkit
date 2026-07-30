import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'otp_screen.dart';
import 'home_screen.dart';

const Color kBrandGreen = Color(0xFF0C831F);
const Color kMintBg = Color(0xFFE8F6F3);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool get _isValid => _phoneController.text.length == 10;

  // Generic grocery-style icons for the decorative backdrop (no real brands).
  static const _icons = [
    Icons.icecream, Icons.local_drink, Icons.egg_alt_outlined, Icons.cookie,
    Icons.local_cafe, Icons.soup_kitchen_outlined, Icons.eco_outlined, Icons.bakery_dining,
    Icons.liquor_outlined, Icons.rice_bowl_outlined, Icons.breakfast_dining, Icons.icecream_outlined,
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_isValid) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpScreen(phone: _phoneController.text)),
    );
  }

  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Decorative grocery grid backdrop
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 50, 12, 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: kMintBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(_icons[index], color: kBrandGreen.withOpacity(0.55), size: 30),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: SafeArea(
                    child: TextButton(
                      onPressed: _skipLogin,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('Skip login',
                          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom card
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kBrandGreen,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Go', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
                        TextSpan(text: 'Fresh', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: kBrandGreen)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("India's fastest app",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text('Log In or Sign Up',
                      style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600])),
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 22, height: 15,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Color(0xFFFF9933), Colors.white, Color(0xFF138808)],
                                    stops: [0.33, 0.5, 0.66],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('+91', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 24, color: Colors.grey.shade300),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Enter mobile number',
                              hintStyle: GoogleFonts.poppins(color: Colors.grey),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            style: GoogleFonts.poppins(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid ? kBrandGreen : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Continue',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                      children: [
                        TextSpan(text: 'Terms of service', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, decoration: TextDecoration.underline)),
                        const TextSpan(text: ' & '),
                        TextSpan(text: 'Privacy policy', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, decoration: TextDecoration.underline)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}