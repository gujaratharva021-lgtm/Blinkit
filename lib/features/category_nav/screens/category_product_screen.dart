import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/state_views.dart';
import '../models/category_models.dart';
import '../providers/category_nav_provider.dart';
import '../routes/category_nav_routes.dart';
import '../widgets/category_placeholder_image.dart';
import '../widgets/category_search_filter_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_grid.dart';
import '../widgets/subcategory_chips.dart';

class CategoryProductScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryProductScreen({super.key, required this.category});

  @override
  State<CategoryProductScreen> createState() => _CategoryProductScreenState();
}

class _CategoryProductScreenState extends State<CategoryProductScreen> {
  static const _pageSize = 8;
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryNavProvider>().openCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryNavProvider>();
    final category = widget.category;
    final allVisible = provider.visibleProducts;
    final shown = allVisible.take(_visibleCount).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildBanner(context, category),
            CategorySearchBar(categoryTitle: category.title),
            const FilterSortBar(),
            const SizedBox(height: 10),
            SubcategoryChips(
              subCategories: category.subCategories,
              selected: provider.activeSubCategory,
              onSelected: (sub) {
                provider.selectSubCategory(sub);
                setState(() => _visibleCount = _pageSize);
              },
            ),
            const SizedBox(height: 6),
            Expanded(child: _buildBody(context, provider, shown, allVisible.length)),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, CategoryModel category) {
    return Container(
      color: category.color.withOpacity(0.10),
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          CategoryPlaceholderImage(icon: category.icon, color: category.color, size: 44, borderRadius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Text(category.title,
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, CategoryNavProvider provider, List shownRaw, int totalCount) {
    final shown = shownRaw.cast<ProductModel>();

    if (provider.productStatus == LoadStatus.loading || provider.productStatus == LoadStatus.idle) {
      return const SkeletonGrid(itemCount: 6);
    }

    if (provider.productStatus == LoadStatus.error) {
      return ErrorView(
        message: 'Something went wrong while loading products.',
        onRetry: provider.retry,
      );
    }

    if (provider.productStatus == LoadStatus.empty || shown.isEmpty) {
      return const EmptyView(icon: Icons.shopping_basket_outlined, message: 'No products found here.');
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shown.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            final product = shown[index];
            return ProductCard(
              product: product,
              onTap: () => CategoryNavRoutes.openProductDetails(context, product),
            );
          },
        ),
        if (_visibleCount < totalCount)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: () => setState(() => _visibleCount += _pageSize),
                child: Text('Load more', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
      ],
    );
  }
}
