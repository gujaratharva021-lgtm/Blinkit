import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/state_views.dart';
import '../models/category_models.dart';
import '../providers/category_nav_provider.dart';
import '../routes/category_nav_routes.dart';
import '../widgets/category_tile.dart';

/// Drop-in widget for the GoFresh home screen: renders "Grocery &
/// Kitchen", "Snacks & Drinks", "Beauty & Personal Care" and "Household
/// Essentials" as 4-column category grids (matches the reference
/// screenshots). Tapping a tile opens [CategoryProductScreen].
class HomeCategorySections extends StatefulWidget {
  const HomeCategorySections({super.key});

  @override
  State<HomeCategorySections> createState() => _HomeCategorySectionsState();
}

class _HomeCategorySectionsState extends State<HomeCategorySections> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CategoryNavProvider>().loadHomeSections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryNavProvider>();

    if (provider.homeStatus == LoadStatus.loading || provider.homeStatus == LoadStatus.idle) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: LoadingView(),
      );
    }

    if (provider.homeStatus == LoadStatus.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ErrorView(
          message: 'Could not load categories right now.',
          onRetry: () => context.read<CategoryNavProvider>().loadHomeSections(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: provider.sections.map((section) => _buildSection(context, section)).toList(),
    );
  }

  Widget _buildSection(BuildContext context, CategorySectionModel section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(section.title,
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: section.title == 'Beauty & Personal Care' ? 3 : 4,
                mainAxisSpacing: section.title == 'Beauty & Personal Care' ? 12 : 10,
                crossAxisSpacing: 8,
                childAspectRatio: section.title == 'Beauty & Personal Care' ? 0.85 : 0.68,
              ),
              itemBuilder: (context, index) {
                final category = section.categories[index];
                return CategoryTile(
                  category: category,
                  onTap: () => CategoryNavRoutes.openCategory(context, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
