import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../constants/asset_constants.dart';
import '../models/category.dart' as models;
import 'product_detail_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;
  const CategoriesScreen({super.key, this.initialCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      final index = _categories
          .indexWhere((c) => c.name == widget.initialCategory);
      if (index != -1) {
        _selectedIndex = index;
      }
    }
  }

  final List<models.Category> _categories = const [
    models.Category(name: 'Fruits', image: AssetConstants.fruits),
    models.Category(name: 'Beverages', image: AssetConstants.beverages),
    models.Category(name: 'Bakery', image: AssetConstants.bakery),
    models.Category(name: 'Biscuits', image: AssetConstants.biscuits),
    models.Category(name: 'Namkeen', image: AssetConstants.namkeen),
    models.Category(name: 'Wafers', image: AssetConstants.wafers),
    models.Category(name: 'Ketchup', image: AssetConstants.ketchup),
    models.Category(name: 'Shampoo', image: AssetConstants.shampoo),
    models.Category(name: 'Soap', image: AssetConstants.soap),
    models.Category(name: 'Personal Care', image: AssetConstants.personalCare),
    models.Category(name: 'Pickle', image: AssetConstants.pickle),
    models.Category(name: 'Puja Items', image: AssetConstants.pujaItems),
    models.Category(name: 'Toys', image: AssetConstants.toys),
    models.Category(name: 'Clothes', image: AssetConstants.clothes),
    models.Category(name: 'Ice Creams', image: AssetConstants.iceCreams),
    models.Category(name: 'Chocolate', image: AssetConstants.chocolate),
    models.Category(name: 'Atta, Rice & Dal', image: AssetConstants.attaRiceDal),
    models.Category(name: 'Oil, Ghee & Masala', image: AssetConstants.oilGheeMasala),
    models.Category(name: 'Dairy, Bread & Eggs', image: AssetConstants.dairyBreadEggs),
    models.Category(name: 'Dry Fruits & Cereals', image: AssetConstants.dryFruitsCereals),
    models.Category(name: 'Kitchenware & Appliances', image: AssetConstants.kitchenwareAppliances),
    models.Category(name: 'Chicken & Meat', image: AssetConstants.chickenMeatFish),
    models.Category(name: 'Tea, Coffee & Milk Drinks', image: AssetConstants.teaCoffeeMilk),
    models.Category(name: 'Instant Food', image: AssetConstants.instantFood),
    models.Category(name: 'Paan Corner', image: AssetConstants.paanCorner),
    models.Category(name: 'Skin & Face', image: AssetConstants.skinFace),
    models.Category(name: 'Feminine Hygiene', image: AssetConstants.feminineHygiene),
    models.Category(name: 'Baby Care', image: AssetConstants.babyCare),
    models.Category(name: 'Health & Pharma', image: AssetConstants.healthPharma),
    models.Category(name: 'Home & Lifestyle', image: AssetConstants.homeLifestyle),
    models.Category(name: 'Cleaners & Repellents', image: AssetConstants.cleanersRepellents),
    models.Category(name: 'Electronics', image: AssetConstants.electronicsCategory),
    models.Category(name: 'Stationery & Games', image: AssetConstants.stationeryGames),
  ];

  Widget _buildCategoryIcon(String imagePath) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
        ),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 100, width: double.infinity, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: 100, color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imagePath,
      height: 100, width: double.infinity, fit: BoxFit.contain,
      placeholder: (_, __) => Container(
        height: 100, color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Container(
        height: 100, color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _categories[_selectedIndex].name;
    final allProducts = context.watch<ProductProvider>().products;
    final products = (allProducts.where((p) => p['category'] == selectedCategory).toList())
        .map((p) => {...p, 'category': p['category'] ?? selectedCategory})
        .toList();
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
            style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
                  onTap: () => setState(() => _selectedIndex = index),
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
                        Container(
                          width: 64,
                          height: 64,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildCategoryIcon(cat.image),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(cat.name,
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
            child: products.isEmpty
                ? Center(
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
            )
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final qty = cart.getQuantityByProductId(product['id']);
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: product,
                        allProducts: products,
                      ),
                    ),
                  ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        child: _buildProductImage(product['image']),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'],
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(product['unit'],
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('?${product['price']}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0C831F))),
                                qty == 0
                                    ? GestureDetector(
                                  onTap: () => context.read<CartProvider>().increment(product['id']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF0C831F),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text('ADD',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                )
                                    : Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.read<CartProvider>()
                                          .decrement(product['id']),
                                      child: Container(
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF0C831F),
                                              borderRadius: BorderRadius.circular(5)),
                                          child: const Icon(Icons.remove, color: Colors.white, size: 14)),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: Text('$qty',
                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold))),
                                    GestureDetector(
                                      onTap: () => context.read<CartProvider>().increment(product['id']),
                                      child: Container(
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF0C831F),
                                              borderRadius: BorderRadius.circular(5)),
                                          child: const Icon(Icons.add, color: Colors.white, size: 14)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                        ],
                      ),
                    ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
              break;
            case 1:
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
              break;
          }
        },
        selectedItemColor: const Color(0xFF0C831F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      ),
    );
  }
}

