import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/state_views.dart' show kGreen;
import '../models/category_models.dart';
import 'category_placeholder_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.getQuantity(product.name);
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: (product.image != null && product.image!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            product.image!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => CategoryPlaceholderImage(
                              icon: product.icon,
                              color: product.color,
                              size: 72,
                              borderRadius: 12,
                            ),
                          ),
                        )
                      : CategoryPlaceholderImage(
                          icon: product.icon,
                          color: product.color,
                          size: 72,
                          borderRadius: 12,
                        ),
                ),
                if (product.discountPercent > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: kGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${product.discountPercent}% OFF',
                          style: GoogleFonts.poppins(
                              fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                if (!product.inStock)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Out of stock',
                          style: GoogleFonts.poppins(
                              fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber[700]),
                const SizedBox(width: 2),
                Text('${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
                    style: GoogleFonts.poppins(fontSize: 10, color: scheme.onSurface.withOpacity(0.6))),
              ],
            ),
            const SizedBox(height: 4),
            Text(product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${product.brand} \u2022 ${product.weight}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 10.5, color: scheme.onSurface.withOpacity(0.55))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\u20b9${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold)),
                      if (product.mrp > product.price)
                        Text('\u20b9${product.mrp.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: scheme.onSurface.withOpacity(0.45),
                                decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                ),
                _AddButton(product: product, qty: qty),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final ProductModel product;
  final int qty;

  const _AddButton({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    if (!product.inStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Notify',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
      );
    }

    if (qty == 0) {
      return GestureDetector(
        onTap: () => cart.addToCart(
            product.name, product.price.round(), product.weight, (product.image ?? (product.image ?? 'placeholder:${product.id}'))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: kGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('ADD',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove, onTap: () => cart.removeFromCart(product.name)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$qty',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          _StepperButton(
              icon: Icons.add,
              onTap: () => cart.addToCart(
                  product.name, product.price.round(), product.weight, (product.image ?? (product.image ?? 'placeholder:${product.id}')))),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
