import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/state_views.dart';
import '../models/category_models.dart';
import '../providers/category_nav_provider.dart';
import '../routes/category_nav_routes.dart';
import '../../../screens/categories_screen.dart';
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
                childAspectRatio: section.title == 'Beauty & Personal Care' ? 0.85 : 0.72,
              ),
              itemBuilder: (context, index) {
                final category = section.categories[index];
                const categoryScreenMap = {
                  'cat_veg_fruits': 'Fruits',
                  'cat_atta_rice_dal': 'Atta, Rice & Dal',
                  'cat_oil_ghee_masala': 'Oil, Ghee & Masala',
                  'cat_dairy_bread_eggs': 'Dairy, Bread & Eggs',
                  'cat_bakery_biscuits': 'Biscuits',
                  'cat_dryfruits_cereals': 'Dry Fruits & Cereals',
                  'cat_kitchenware': 'Kitchenware & Appliances',
                  'cat_chicken_meat_fish': 'Chicken & Meat',
                  'cat_chips_namkeen': 'Namkeen',
                  'cat_sweets_choco': 'Chocolate',
                  'cat_drinks_juices': 'Beverages',
                  'cat_tea_coffee': 'Tea, Coffee & Milk Drinks',
                  'cat_instant_food': 'Instant Food',
                  'cat_sauces_spreads': 'Ketchup',
                  'cat_paan_corner': 'Paan Corner',
                  'cat_ice_creams': 'Ice Creams',
                  'cat_bath_body': 'Soap',
                  'cat_hair': 'Shampoo',
                  'cat_skin_face': 'Skin & Face',
                  'cat_feminine_hygiene': 'Feminine Hygiene',
                  'cat_baby_care': 'Baby Care',
                  'cat_health_pharma': 'Health & Pharma',
                  'cat_home_lifestyle': 'Home & Lifestyle',
                  'cat_cleaners_repellents': 'Cleaners & Repellents',
                  'cat_electronics': 'Electronics',
                  'cat_stationery_games': 'Stationery & Games',
                };
                return CategoryTile(
                  category: category,
                  onTap: () {
                    final target = categoryScreenMap[category.id] ?? category.title;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoriesScreen(initialCategory: target)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
