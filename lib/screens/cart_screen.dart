import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'address_screen.dart';

const Color kBrandGreen = Color(0xFF0C831F);
const Color kLightGreenBg = Color(0xFFEAF7EA);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  static const int deliveryFee = 25;
  static const int platformFee = 5;
  static const double freeDeliveryThreshold = 299;

  Widget _buildCartImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: 60, height: 60, color: kLightGreenBg,
              child: const Icon(Icons.image_not_supported, color: kBrandGreen)));
    }
    return Image.network(imagePath, width: 60, height: 60, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            width: 60, height: 60, color: kLightGreenBg,
            child: const Icon(Icons.image_not_supported, color: kBrandGreen)));
  }

  Widget _billRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.grey[600])),
          Text(value, style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? kBrandGreen : Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.cartTotal + deliveryFee + platformFee;
    final remaining = freeDeliveryThreshold - cart.cartTotal;
    final unlocked = remaining <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('My Cart (${cart.cartCount} items)',
            style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: cart.cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Your cart is empty',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Shop Now',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 110),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked ? 'Yay! Free delivery unlocked' : 'Delivery in 10 minutes',
                      style: GoogleFonts.poppins(
                          color: kBrandGreen, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    if (!unlocked) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Add items worth ₹${remaining.toStringAsFixed(0)} more to unlock FREE delivery',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...cart.cartItems.values.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildCartImage(item.image),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(item.unit, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('₹${item.price}', style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: kBrandGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => context.read<CartProvider>().removeFromCart(item.name),
                            child: const SizedBox(width: 28, height: 32,
                                child: Icon(Icons.remove, color: Colors.white, size: 16)),
                          ),
                          SizedBox(
                            width: 24,
                            child: Text('${item.quantity}', textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          InkWell(
                            onTap: () => context.read<CartProvider>()
                                .addToCart(item.name, item.price, item.unit, item.image),
                            child: const SizedBox(width: 28, height: 32,
                                child: Icon(Icons.add, color: Colors.white, size: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const Divider(height: 24),
              Text('Bill details', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              _billRow('Item Total', '₹${cart.cartTotal}'),
              _billRow('Delivery Fee', unlocked ? 'FREE' : '₹$deliveryFee'),
              _billRow('Platform Fee', '₹$platformFee'),
              const Divider(),
              _billRow('Grand Total', '₹${unlocked ? cart.cartTotal + platformFee : total}', isBold: true),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Material(
                  color: kBrandGreen,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isLoading ? null : () {
                      final items = cart.cartItems.values.map((item) => {
                        'name': item.name,
                        'price': item.price,
                        'quantity': item.quantity,
                      }).toList();
                      final grandTotal = unlocked ? cart.cartTotal + platformFee : total;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddressScreen(
                            items: items,
                            totalAmount: grandTotal,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${unlocked ? cart.cartTotal + platformFee : total}',
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Row(
                            children: [
                              Text('Proceed to Address',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}