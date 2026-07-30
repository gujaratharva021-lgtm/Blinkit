import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C831F),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                Text(
                  'blinkit',
                  style: GoogleFonts.poppins(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "India's Fastest Delivery App",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                // Offer Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C831F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '1,000+ products',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'delivered at your doorstep',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'FREE',
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0C831F),
                                  height: 1,
                                ),
                              ),
                              Text(
                                'DELIVERY',
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0C831F),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'on your first 10 orders',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Delivery Boy
                Container(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBuilding(60, 80),
                            _buildBuilding(80, 110),
                            _buildBuilding(50, 70),
                            _buildBuilding(70, 100),
                            _buildBuilding(55, 75),
                            _buildBuilding(75, 95),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        child: Column(
                          children: [
                            Container(
                              width: 70, height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delivery_dining,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.electric_scooter,
                                  color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuilding(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}