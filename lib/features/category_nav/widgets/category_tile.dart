import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_models.dart';
import 'category_placeholder_image.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryPlaceholderImage(
            icon: category.icon,
            color: category.color,
            size: 64,
            borderRadius: 18,
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
          ),
        ],
      ),
    );
  }
}
