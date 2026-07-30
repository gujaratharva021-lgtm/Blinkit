import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offer_screen.dart';
import 'home_screen.dart';

const Color kNeonGreen = Color(0xFF7ED321);
const Color kSplashBg = Color(0xFF0A0F0A);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => token != null && token.isNotEmpty
                ? const HomeScreen()
                : const OfferScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSplashBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFAEEA00), kNeonGreen],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: kNeonGreen.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.bolt, size: 60, color: Color(0xFF0A0F0A)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Go',
                          style: GoogleFonts.poppins(
                              fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Fresh',
                          style: GoogleFonts.poppins(
                              fontSize: 44, fontWeight: FontWeight.w800, color: kNeonGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Groceries in a ',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                        ),
                        TextSpan(
                          text: 'Blink.',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600, color: kNeonGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, color: kNeonGreen, size: 16),
                      const SizedBox(width: 6),
                      Container(width: 1, height: 14, color: Colors.white24),
                      const SizedBox(width: 8),
                      Text('10 MIN ',
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w800, color: kNeonGreen)),
                      Text('DELIVERY',
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _feature(Icons.rocket_launch, 'FRESH', 'Handpicked\nfor you'),
                        _divider(),
                        _feature(Icons.timer_outlined, 'FAST', 'Delivered in\n10 minutes'),
                        _divider(),
                        _feature(Icons.verified_user_outlined, 'RELIABLE', 'You can\ncount on us'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white24);

  Widget _feature(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: kNeonGreen, size: 20),
          const SizedBox(height: 6),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54, height: 1.3)),
        ],
      ),
    );
  }
}
