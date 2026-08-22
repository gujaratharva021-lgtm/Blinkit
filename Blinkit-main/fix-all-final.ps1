$repoPath = "C:\Users\ABC\Downloads\Blinkit-main\Blinkit-main"

# ===== FIX 1: cart_provider.dart - local (device-only) cart for demo/mock products =====
$cartProviderContent = @'
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  int _totalItems = 0;
  double _totalAmount = 0;
  bool _isLoading = false;

  // Local-only cart for demo/mock catalog products that don't exist in the
  // backend database yet (their id is a non-numeric string like
  // "cat_dairy_p3"). These are kept in-memory only (not synced to the
  // server) so the Add button and View Cart bar still work for them
  // instead of silently failing.
  final Map<String, Map<String, dynamic>> _localItems = {};

  List<dynamic> get items => _items;
  bool get isLoading => _isLoading;

  int get _localItemsCount =>
      _localItems.values.fold(0, (sum, item) => sum + (item['quantity'] as int));

  double get _localItemsTotal => _localItems.values.fold(
      0.0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));

  int get cartCount => _totalItems + _localItemsCount;

  double get cartTotal => _totalAmount + _localItemsTotal;

  List<Map<String, dynamic>> get localCartItems => _localItems.values.toList();

  int? getCartItemId(int productId) {
    for (final item in _items) {
      if (item['product_id'] == productId) return item['id'];
    }
    return null;
  }

  int getQuantityByProductId(dynamic productId) {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);
    if (realId != null) {
      for (final item in _items) {
        if (item['product_id'] == realId) return item['quantity'];
      }
      return 0;
    }
    final key = productId.toString();
    return (_localItems[key]?['quantity'] as int?) ?? 0;
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getCart();
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
    } catch (e) {
      debugPrint('loadCart error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(dynamic productId,
      {int quantity = 1, Map<String, dynamic>? productData}) async {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null || realId <= 0) {
      // Demo/mock product without a real backend id -- add to the
      // local-only cart instead of failing.
      final key = productId.toString();
      final existing = _localItems[key];
      if (existing != null) {
        existing['quantity'] = (existing['quantity'] as int) + quantity;
      } else {
        _localItems[key] = {
          'id': key,
          'name': productData?['name'] ?? 'Item',
          'price': productData?['price'] ?? 0,
          'image': productData?['image'] ?? '',
          'quantity': quantity,
        };
      }
      notifyListeners();
      return;
    }

    try {
      final data = await ApiService.addToCart(realId, quantity);
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('addProduct error: $e');
      throw Exception('Could not add item to cart. Please try again.');
    }
  }

  Future<void> increment(dynamic productId, {Map<String, dynamic>? productData}) async {
    await addProduct(productId, quantity: 1, productData: productData);
  }

  Future<void> decrement(dynamic productId) async {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null) {
      final key = productId.toString();
      final existing = _localItems[key];
      if (existing == null) return;
      final currentQty = existing['quantity'] as int;
      if (currentQty <= 1) {
        _localItems.remove(key);
      } else {
        existing['quantity'] = currentQty - 1;
      }
      notifyListeners();
      return;
    }

    final itemId = getCartItemId(realId);
    if (itemId == null) return;
    final currentQty = getQuantityByProductId(realId);
    try {
      Map<String, dynamic> data;
      if (currentQty <= 1) {
        data = await ApiService.removeCartItem(itemId);
      } else {
        data = await ApiService.updateCartItem(itemId, currentQty - 1);
      }
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('decrement error: $e');
      throw Exception('Could not update cart. Please try again.');
    }
  }

  Future<void> removeItemByProductId(dynamic productId) async {
    final int? realId = productId is int
        ? productId
        : (productId is String ? int.tryParse(productId) : null);

    if (realId == null) {
      _localItems.remove(productId.toString());
      notifyListeners();
      return;
    }

    final itemId = getCartItemId(realId);
    if (itemId == null) return;
    try {
      final data = await ApiService.removeCartItem(itemId);
      _items = data['items'] ?? [];
      _totalItems = data['total_items'] ?? 0;
      _totalAmount = (data['total_amount'] ?? 0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('removeItemByProductId error: $e');
    }
  }

  void clearCartLocal() {
    _items = [];
    _totalItems = 0;
    _totalAmount = 0;
    _localItems.clear();
    notifyListeners();
  }
}
'@

Set-Content -Path "$repoPath\lib\providers\cart_provider.dart" -Value $cartProviderContent -Encoding UTF8 -NoNewline
Write-Host "OK: cart_provider.dart - local cart fallback added (demo products now add successfully)" -ForegroundColor Green

# ===== FIX 2: product_card.dart - remove OFF badge and Out of stock badge =====
$productCardContent = @'
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/state_views.dart' show kGreen;
import '../models/category_models.dart';
import 'category_placeholder_image.dart';

Map<String, dynamic> productCartData(ProductModel p) => {
      'id': p.id,
      'name': p.name,
      'brand': p.brand,
      'weight': p.weight,
      'price': p.price,
      'image': p.image,
    };

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.getQuantityByProductId(product.id);
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: (product.image != null && product.image!.isNotEmpty)
                  ? (product.image!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.contain,
                          memCacheWidth: 240,
                          filterQuality: FilterQuality.low,
                          placeholder: (_, __) => const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (_, __, ___) => CategoryPlaceholderImage(
                            icon: product.icon,
                            color: product.color,
                            size: 100,
                            borderRadius: 0,
                          ),
                        )
                      : Image.asset(
                          product.image!,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.contain,
                          cacheWidth: 240,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (_, __, ___) => CategoryPlaceholderImage(
                            icon: product.icon,
                            color: product.color,
                            size: 100,
                            borderRadius: 0,
                          ),
                        ))
                  : CategoryPlaceholderImage(
                      icon: product.icon,
                      color: product.color,
                      size: 100,
                      borderRadius: 0,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

    if (qty == 0) {
      return GestureDetector(
        onTap: () async {
          try {
            await cart.increment(product.id, productData: productCartData(product));
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not add item. Please try again.')),
              );
            }
          }
        },
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
          _StepperButton(icon: Icons.remove, onTap: () => cart.decrement(product.id)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$qty',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          _StepperButton(
              icon: Icons.add,
              onTap: () => cart.increment(product.id, productData: productCartData(product))),
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
'@

Set-Content -Path "$repoPath\lib\features\category_nav\widgets\product_card.dart" -Value $productCardContent -Encoding UTF8 -NoNewline
Write-Host "OK: product_card.dart - OFF badge and Out of stock badge removed" -ForegroundColor Green

# ===== FIX 3: categories_screen.dart - View Cart bar with thumbnails =====
$categoriesScreenContent = @'
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
import '../services/api_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;
  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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

  String _cartImageUrl(dynamic item) {
    final product = item['product'] ?? {};
    final raw = product['image_url']?.toString() ?? '';
    if (raw.isEmpty) return 'assets/images/placeholder.png';
    if (raw.startsWith('http') || raw.startsWith('assets/')) return raw;
    final host = ApiService.baseUrl.replaceAll('/api/v1', '');
    return '$host$raw';
  }

  Widget _buildThumbImage(String imagePath, {double height = 40}) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 16),
        ),
      );
    } else {
      return Image.network(
        imagePath,
        height: height,
        width: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 16),
        ),
      );
    }
  }

  Widget _buildCartThumbnails(CartProvider cart) {
    final images = [
      ...cart.items.map((item) => _cartImageUrl(item)),
      ...cart.localCartItems.map((item) => (item['image'] ?? '').toString()),
    ].take(2).toList();
    if (images.isEmpty) return const SizedBox(width: 0, height: 40);
    return SizedBox(
      width: images.length > 1 ? 54 : 40,
      height: 40,
      child: Stack(
        children: [
          for (int i = 0; i < images.length; i++)
            Positioned(
              left: i * 22.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: _buildThumbImage(images[i], height: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryNavProvider>();
    final products = provider.visibleProducts;
    final cart = context.watch<CartProvider>();

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
        floatingActionButton: cart.cartCount > 0
            ? Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C831F),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCartThumbnails(cart),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('View cart',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${cart.cartCount} item${cart.cartCount > 1 ? 's' : ''}',
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(width: 18),
                          const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null,
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
'@

Set-Content -Path "$repoPath\lib\screens\categories_screen.dart" -Value $categoriesScreenContent -Encoding UTF8 -NoNewline
Write-Host "OK: categories_screen.dart - View Cart bar with thumbnails" -ForegroundColor Green

# ===== FIX 4: category_product_screen.dart (the "Atta, Rice & Dal" style screen) - add View Cart bar =====
$categoryProductScreenContent = @'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/state_views.dart';
import '../../../providers/cart_provider.dart';
import '../../../services/api_service.dart';
import '../../../screens/cart_screen.dart';
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

  String _cartImageUrl(dynamic item) {
    final product = item['product'] ?? {};
    final raw = product['image_url']?.toString() ?? '';
    if (raw.isEmpty) return 'assets/images/placeholder.png';
    if (raw.startsWith('http') || raw.startsWith('assets/')) return raw;
    final host = ApiService.baseUrl.replaceAll('/api/v1', '');
    return '$host$raw';
  }

  Widget _buildThumbImage(String imagePath, {double height = 40}) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 16),
        ),
      );
    } else {
      return Image.network(
        imagePath,
        height: height,
        width: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 16),
        ),
      );
    }
  }

  Widget _buildCartThumbnails(CartProvider cart) {
    final images = [
      ...cart.items.map((item) => _cartImageUrl(item)),
      ...cart.localCartItems.map((item) => (item['image'] ?? '').toString()),
    ].take(2).toList();
    if (images.isEmpty) return const SizedBox(width: 0, height: 40);
    return SizedBox(
      width: images.length > 1 ? 54 : 40,
      height: 40,
      child: Stack(
        children: [
          for (int i = 0; i < images.length; i++)
            Positioned(
              left: i * 22.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: _buildThumbImage(images[i], height: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryNavProvider>();
    final category = widget.category;
    final allVisible = provider.visibleProducts;
    final shown = allVisible.take(_visibleCount).toList();
    final cart = context.watch<CartProvider>();

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
      floatingActionButton: cart.cartCount > 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C831F),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCartThumbnails(cart),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('View cart',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('${cart.cartCount} item${cart.cartCount > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(width: 18),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (category.image != null && category.image!.isNotEmpty)
                ? Image.asset(
                    category.image!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CategoryPlaceholderImage(
                        icon: category.icon, color: category.color, size: 44, borderRadius: 12),
                  )
                : CategoryPlaceholderImage(
                    icon: category.icon, color: category.color, size: 44, borderRadius: 12),
          ),
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
            childAspectRatio: 0.72,
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
'@

Set-Content -Path "$repoPath\lib\features\category_nav\screens\category_product_screen.dart" -Value $categoryProductScreenContent -Encoding UTF8 -NoNewline
Write-Host "OK: category_product_screen.dart - View Cart bar added (fixes 'Atta, Rice & Dal' type screens)" -ForegroundColor Green

Write-Host "`nAll fixes applied. Ab 'flutter pub get' aur 'flutter run' se test karein." -ForegroundColor Cyan
