import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _highlightsExpanded = true;
  bool _infoExpanded = true;

  String _getGoodFor(String category) {
    switch (category) {
      case 'Fruits': return 'Health & Immunity';
      case 'Ice Creams': return 'Dessert & Treats';
      case 'Chocolate': return 'Snacking & Gifting';
      case 'Beverages':
      case 'Cold Drinks': return 'Refreshment & Hydration';
      case 'Bakery': return 'Breakfast & Snacking';
      case 'Biscuits': return 'Tea Time & Snacking';
      case 'Namkeen':
      case 'Wafers':
      case 'Snacks': return 'Evening Snacking';
      case 'Shampoo':
      case 'Soap':
      case 'Personal Care': return 'Personal Hygiene';
      case 'Clothes': return 'Fashion & Lifestyle';
      case 'Toys': return 'Kids & Entertainment';
      case 'Ketchup':
      case 'Pickle': return 'Cooking & Condiments';
      case 'Puja Items': return 'Spiritual & Religious';
      default: return 'Daily Essentials';
    }
  }

  String _getDietaryPref(String category) {
    switch (category) {
      case 'Clothes':
      case 'Toys':
      case 'Shampoo':
      case 'Soap':
      case 'Personal Care':
      case 'Puja Items': return 'N/A';
      case 'Ice Creams':
      case 'Chocolate':
      case 'Bakery': return 'Veg / Non-Veg';
      default: return 'Veg';
    }
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(color: Colors.grey[200]),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cart = context.watch<CartProvider>();
    final qty = cart.getQuantity(product['name']);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
                    ),
                    child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: _buildProductImage(product['image']),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.flash_on,
                                        color: Colors.white, size: 12),
                                    Text('10 mins',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(product['name'],
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Net quantity: ${product['unit']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C831F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('â‚¹${product['price']}',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                  'MRP â‚¹${(product['price'] * 1.3).toInt()}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      decoration:
                                      TextDecoration.lineThrough)),
                              const SizedBox(width: 8),
                              Text(
                                  'â‚¹${(product['price'] * 0.3).toInt()} OFF',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.replay,
                                      size: 30, color: Colors.grey),
                                  const SizedBox(height: 6),
                                  Text('Easy Refunds',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.delivery_dining,
                                      size: 30, color: Colors.grey),
                                  const SizedBox(height: 6),
                                  Text('Fast Delivery',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Highlights
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() =>
                            _highlightsExpanded = !_highlightsExpanded),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Highlights',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Icon(_highlightsExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ),
                          if (_highlightsExpanded)
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  _highlightRow('Product Type', product['category']),
                                  _highlightRow('Good For', _getGoodFor(product['category'])),
                                  _highlightRow('Dietary Preference', _getDietaryPref(product['category'])),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Information
                    Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(
                                    () => _infoExpanded = !_infoExpanded),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Information',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Icon(_infoExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ),
                          if (_infoExpanded)
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children: [
                                  _highlightRow('Disclaimer',
                                      'All images are for representational purposes only. It is advised that you read the batch and manufacturing details before consuming.'),
                                  _highlightRow('Manufacturer',
                                      'Fresh Farm Produce Pvt. Ltd., Mumbai, Maharashtra'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            color: Theme.of(context).colorScheme.onSurface),
                        if (cart.cartCount > 0)
                          Positioned(
                            top: 4, right: 4,
                            child: Container(
                              width: 16, height: 16,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF0C831F),
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text('${cart.cartCount}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: qty == 0
                        ? ElevatedButton(
                      onPressed: () =>
                          context.read<CartProvider>().addToCart(
                              product['name'],
                              product['price'],
                              product['unit'],
                              product['image']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C831F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Add to Cart',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    )
                        : Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C831F),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => context
                                .read<CartProvider>()
                                .removeFromCart(product['name']),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Icon(Icons.remove,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                          Text('$qty',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () =>
                                context.read<CartProvider>().addToCart(
                                    product['name'],
                                    product['price'],
                                    product['unit'],
                                    product['image']),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Icon(Icons.add,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style:
                GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
