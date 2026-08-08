import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/state_views.dart' show kGreen;
import '../models/category_models.dart';

class SubcategoryChips extends StatelessWidget {
  final List<SubCategoryModel> subCategories;
  final SubCategoryModel? selected;
  final ValueChanged<SubCategoryModel?> onSelected;

  const SubcategoryChips({
    super.key,
    required this.subCategories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (subCategories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: subCategories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final sub = isAll ? null : subCategories[index - 1];
          final isSelected = selected?.id == sub?.id;
          return ChoiceChip(
            label: Text(isAll ? 'All' : sub!.title,
                style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : null)),
            selected: isSelected,
            onSelected: (_) => onSelected(sub),
            selectedColor: kGreen,
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}
