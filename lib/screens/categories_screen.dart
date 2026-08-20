import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../features/category_nav/data/category_mock_data.dart';
import '../features/category_nav/models/category_models.dart';
import '../features/category_nav/providers/category_nav_provider.dart';
import '../features/category_nav/widgets/category_placeholder_image.dart';
import '../features/category_nav/widgets/product_card.dart';
import '../features/category_nav/widgets/skeleton_grid.dart';
import '../features/category_nav/screens/product_details_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../widgets/cart_floating_bar.dart';
import '../widgets/cart_floating_bar.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;
  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Flattened list of every CategoryModel across all sections, used to
  // drive the left sidebar (same source of truth as the Home screen).
  late final List<CategoryModel> _categories = CategoryMockData.sections
      .expand((s) => s.categories)
      .toList();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      final index = _categories.indexWhere((c) => c.title == widget.initialCategory);
      if (index != -1) {
        _selectedIndex = index;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryNavProvider>().openCategory(_categories[_selectedIndex]);
    });
  }

  void _selectCategory(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    context.read<CategoryNavProvider>().openCategory(_categories[index]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryNavProvider>();
    final products = provider.visibleProducts;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text('Categories',
              style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        ),
        body: Row(
          children: [
            Container(
              width: 90,
              color: Theme.of(context).colorScheme.surface,
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => _selectCategory(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0C831F).withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? const Color(0xFF0C831F) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: (cat.image != null && cat.image!.isNotEmpty)
                                  ? Image.asset(
                                      cat.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => CategoryPlaceholderImage(
                                        icon: cat.icon,
                                        color: cat.color,
                                        size: 64,
                                        borderRadius: 16,
                                      ),
                                    )
                                  : CategoryPlaceholderImage(
                                      icon: cat.icon,
                                      color: cat.color,
                                      size: 64,
                                      borderRadius: 16,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(cat.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? const Color(0xFF0C831F) : Colors.grey),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildBody(context, provider, products),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                break;
              case 1:
                break;
              case 2:
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                break;
            }
          },
          selectedItemColor: const Color(0xFF0C831F),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        floatingActionButton: const CartFloatingBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, CategoryNavProvider provider, List<ProductModel> products) {
    if (provider.productStatus == LoadStatus.loading || provider.productStatus == LoadStatus.idle) {
      return const SkeletonGrid(itemCount: 6);
    }

    if (provider.productStatus == LoadStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Something went wrong.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: provider.retry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Coming Soon!',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
          ),
        );
      },
    );
  }
}
