import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import '../widgets/wishlist_intro_sheet.dart';
import '../features/category_nav/screens/home_category_sections.dart';
import 'notifications/notification_list_screen.dart';
import '../features/category_nav/data/category_mock_data.dart';
import '../features/category_nav/models/category_models.dart';
import '../features/category_nav/routes/category_nav_routes.dart';

class HomeScreen extends StatefulWidget {
  final bool showWishlistIntro;
  const HomeScreen({super.key, this.showWishlistIntro = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showWishlistIntro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showWishlistIntro(context);
      });
    }
  }

  final List<Map<String, dynamic>> _banners = [
    {'title': 'Dairy Products', 'subtitle': 'Pure & fresh daily', 'color': Color(0xFF2196F3), 'image': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600'},
    {'title': 'Fresh Fruits', 'subtitle': 'Handpicked for you', 'color': Color(0xFFFF9800), 'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600'},
    {'title': 'Snacks & Drinks', 'subtitle': 'Your favourite brands', 'color': Color(0xFF0C831F), 'image': 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=600'},
    {'title': 'Bakery Fresh', 'subtitle': 'Baked fresh every day', 'color': Color(0xFF795548), 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600'},
  ];

  final List<Map<String, dynamic>> _products = [
    // --- Fruits ---
    {'name': 'Apple', 'price': 120, 'unit': '4 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/Apple.png'},
    {'name': 'Banana', 'price': 45, 'unit': '6 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/banana.png'},
    {'name': 'Black Grapes', 'price': 80, 'unit': '500g', 'category': 'Fruits', 'image': 'assets/images/Fruits/Black Grapes.png'},
    {'name': 'Chiku', 'price': 50, 'unit': '4 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/Chiku.png'},
    {'name': 'Dragon Fruit', 'price': 150, 'unit': '1 pc', 'category': 'Fruits', 'image': 'assets/images/Fruits/Dragon fruits.png'},
    {'name': 'Green Grapes', 'price': 80, 'unit': '500g', 'category': 'Fruits', 'image': 'assets/images/Fruits/Green Grapes.png'},
    {'name': 'Mango', 'price': 80, 'unit': '2 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/Mango.png'},
    {'name': 'Oranges', 'price': 60, 'unit': '4 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/Oranges.png'},
    {'name': 'Papaya', 'price': 50, 'unit': '1 pc', 'category': 'Fruits', 'image': 'assets/images/Fruits/Papaya.png'},
    {'name': 'Pineapple', 'price': 60, 'unit': '1 pc', 'category': 'Fruits', 'image': 'assets/images/Fruits/Pineapple.png'},
    {'name': 'Pomegranate', 'price': 90, 'unit': '1 pc', 'category': 'Fruits', 'image': 'assets/images/Fruits/Pomogranate.png'},
    {'name': 'Strawberries', 'price': 100, 'unit': '250g', 'category': 'Fruits', 'image': 'assets/images/Fruits/Strawberries.png'},
    {'name': 'Watermelon', 'price': 60, 'unit': '1 pc', 'category': 'Fruits', 'image': 'assets/images/Fruits/Watermelon.png'},

    // --- Chocolate ---
    {'name': 'Amul Chocolate Milk', 'price': 40, 'unit': '200ml', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/amul_chocolate_milk.jpg'},
    {'name': '5 Star Chocolate', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/cadbury_5star.jpg'},    {'name': 'Dairy Milk Small', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/dairy_milk_small.jpg'},
    {'name': 'Dairy Milk', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Dairy_milk.png'},
    {'name': 'Dark Fantasy Pie', 'price': 30, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/DarkFantasy_pie.jpg'},
    {'name': 'Dark Fantasy', 'price': 35, 'unit': '1 pack', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/dark_fantasy.jpg'},
    {'name': 'Hershey Dark', 'price': 60, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Dark_Hersheys.jpg'},
    {'name': 'Fantasy Dark Chocolate', 'price': 25, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Fantasy_dark_chocolate.jpg'},
    {'name': 'Ferrero Rocher', 'price': 120, 'unit': '3 pcs', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/ferrero-rocher.jpg'},
    {'name': 'KitKat Truffle', 'price': 40, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Kitkat_Truffle.jpg'},
    {'name': 'Mars', 'price': 50, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Mars.jpg'},
    {'name': 'Perk', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Perk.jpg'},
    {'name': 'Silk', 'price': 80, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Silk.jpg'},
    {'name': 'Snickers', 'price': 50, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Snickers.jpg'},
    {'name': 'KitKat', 'price': 30, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/KitKat.png'},
    {'name': 'Hersheys', 'price': 70, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/Hersheys.png'},

    // --- Beverages ---
    {'name': '7UP', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/7ups.png'},
    {'name': '250ml Slice Soft', 'price': 30, 'unit': '250ml', 'category': 'Beverages', 'image': 'assets/images/Beverages/250ml-slice-soft.jpg'},
    {'name': 'Big Cola', 'price': 50, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/big-cola.png'},
    {'name': 'Bisleri Soda', 'price': 20, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Bisleri Soda.png'},
    {'name': 'Club Soda', 'price': 20, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Club-soda.jpg'},
    {'name': 'Coca Cola', 'price': 40, 'unit': '1 can', 'category': 'Beverages', 'image': 'assets/images/Beverages/Coco_cola.png'},
    {'name': 'Coke Zero', 'price': 50, 'unit': '1 can', 'category': 'Beverages', 'image': 'assets/images/Beverages/Coke zero.png'},
    {'name': 'Diet Coke', 'price': 50, 'unit': '1 can', 'category': 'Beverages', 'image': 'assets/images/Beverages/Diet Coke.png'},
    {'name': 'Fanta Strawberry', 'price': 40, 'unit': '1 can', 'category': 'Beverages', 'image': 'assets/images/Beverages/Fanta Strawberry.png'},
    {'name': 'Fanta', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Fanta.png'},
    {'name': 'Fanta Pineapple', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/fanta-pineapple.png'},
    {'name': 'Green Tea', 'price': 80, 'unit': '1 pack', 'category': 'Beverages', 'image': 'assets/images/Beverages/Green tea.png'},
    {'name': 'Lemon Soda', 'price': 30, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Lemon_soda.jpg'},
    {'name': 'Limca', 'price': 30, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/limca.jpg'},
    {'name': 'Maaza', 'price': 30, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/maaza.png'},
    {'name': 'Minute Maid Pulpy', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Minute-Maid-Pulpy.png'},
    {'name': 'Mirinda', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Mirinda.jpg'},
    {'name': 'Red Bull', 'price': 120, 'unit': '1 can', 'category': 'Beverages', 'image': 'assets/images/Beverages/red-bull.png'},
    {'name': 'Sprite', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Sprite.png'},
    {'name': 'Thums Up', 'price': 40, 'unit': '1 bottle', 'category': 'Beverages', 'image': 'assets/images/Beverages/Thums UP.jpg'},

    // --- Ice Creams ---
    {'name': 'Amul Belgian Chocolate', 'price': 120, 'unit': '1 cone', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Amul Belgian chocolate.png'},
    {'name': 'Amul Brick Cookies', 'price': 80, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Amul Brick cookies.png'},
    {'name': 'Amul Chocolate', 'price': 60, 'unit': '1 cone', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Amul Chocolate.jpg'},
    {'name': 'Amul Crunch Delight Cone', 'price': 70, 'unit': '1 cone', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Amul Crunch Delight cone.jpg'},
    {'name': 'Amul Gold Tricone Chocolate', 'price': 80, 'unit': '1 cone', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Amul Gold Tricone Chocolate.png'},
    {'name': 'Amul Tricone Chocolate', 'price': 70, 'unit': '1 cone', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Amul Tricone Chocolate.png'},
    {'name': 'Butterscotch Chocolate Mango', 'price': 150, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Butterscotch_Chocolate_Mango.jpg'},
    {'name': 'Chocochips', 'price': 130, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Chocochips.png'},
    {'name': 'Chocolate Ice Cream', 'price': 130, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Chocolate icecream.png'},
    {'name': 'Creamy Deliciousness', 'price': 140, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/creamy-deliciousness.jpg'},
    {'name': 'Kwality Walls Kulfi Tub', 'price': 100, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Kwality walls kulfi tub.png'},
    {'name': 'Kwality Walls Milk Cake', 'price': 30, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Kwality walls milk cake.png'},
    {'name': 'Kwality Walls Magnum Chocolate Truffle', 'price': 120, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/kwality-walls-magnum-chocolate-truffle-ice-cream.png'},
    {'name': 'Kwality Walls Sandwich', 'price': 40, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/kwality-walls-sandwich.png'},
    {'name': 'Magnum Almond Ice Cream', 'price': 120, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum Almond ice cream.png'},
    {'name': 'Magnum Almond', 'price': 110, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum Almond.png'},    {'name': 'Magnum Chocolate', 'price': 110, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum Chocolate.png'},
    {'name': 'Magnum Dark Chocolate', 'price': 120, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum dark chocolate.png'},
    {'name': 'Magnum Ice Cream', 'price': 110, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum ice cream.png'},
    {'name': 'Sweet Delicious Oreo', 'price': 140, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Sweet-delicious oreo.jpg'},

    // --- Bakery ---
    {'name': 'Bar Cake Orange', 'price': 20, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Bar cake Orange.jpg'},
    {'name': 'Britannia Fruit Cake', 'price': 50, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Britannia Fruit cake.png'},
    {'name': 'Fruit Cake Eggless Britannia', 'price': 60, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Fruit-Cake-Eggless-Britannia.jpg'},
    {'name': 'Gobbles Choco', 'price': 30, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Gobbles_Choco.jpg'},
    {'name': 'Gobbles Fruit', 'price': 30, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Gobbles_Fruit.jpg'},
    {'name': 'Malkist Cheese', 'price': 30, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Malkist Cheese.jpg'},
    {'name': 'Milk and Egg Cake', 'price': 40, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/milk-and-egg cake.jpg'},
    {'name': 'Monginis Choco Bar', 'price': 25, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Monginis choco bar.jpg'},
    {'name': 'Monginis Swiss Roll', 'price': 35, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/monginis-swiss-roll.jpg'},
    {'name': 'Muffins', 'price': 40, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/muffills.png'},
    {'name': 'Nuts and Raisin Cake', 'price': 50, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Nuts and raisin cake.jpg'},
    {'name': 'Triple Choco Swiss Roll', 'price': 45, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Triple choco Swiss Roll.jpg'},
    {'name': 'Fudge It', 'price': 30, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Fudge it.png'},
    {'name': 'Malkist Chocolate', 'price': 30, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Malkist chocolate.png'},
    {'name': 'Monginis Fruit Bar', 'price': 25, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Monginis Fruit bar.png'},
    {'name': 'Red Velvet Cake', 'price': 80, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Red velvet cake.png'},
    {'name': 'Vanilla Cake', 'price': 70, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Vanilla cake.png'},
    {'name': 'Britannia Cake', 'price': 40, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/britannia-cake.png'},
    {'name': 'Cake Choco Chill', 'price': 35, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Cake choco chill.png'},
    {'name': 'Double Choco Chips', 'price': 45, 'unit': '1 pc', 'category': 'Bakery', 'image': 'assets/images/Bakery/Double choco chips.png'},

    // --- Biscuits ---
    {'name': 'Parle-G', 'price': 10, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/parleG.jpg'},
    {'name': 'Bourbon', 'price': 20, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Bourbon.jpg'},
    {'name': 'Marie', 'price': 25, 'unit': '200g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Marie.jpg'},
    {'name': 'KrackJack', 'price': 20, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/KrackJack.jpg'},
    {'name': 'Good Day', 'price': 30, 'unit': '150g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Good Day.jpg'},
    {'name': 'Dark Fantasy', 'price': 50, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Dark Fantasy Choco Fills.jpg'},
    {'name': 'Hide & Seek', 'price': 30, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Hide & Seek.jpg'},
    {'name': 'Milk Bikis', 'price': 20, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Milk Bikis.jpg'},
    {'name': 'Nice', 'price': 15, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Nice.jpg'},
    {'name': 'Tiger', 'price': 20, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Tiger.jpg'},
    {'name': 'Treat', 'price': 30, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Treat.jpg'},
    {'name': 'Butter Biscuit', 'price': 25, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Butter.jpg'},

    // --- Namkeen ---
    {'name': 'Bhujia', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Bhujia.jpg'},
    {'name': 'Bhujia Green', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Bhujia(1).jpg'},
    {'name': 'Chakli', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Chakli.jpg'},
    {'name': 'Chana Dal', 'price': 35, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Chana Dal.jpg'},
    {'name': 'Chana Dal Green', 'price': 35, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Chana Dal(1).jpg'},
    {'name': 'Chivda', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/chivda.jpg'},
    {'name': 'Farsan', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Farsan.jpg'},
    {'name': 'Laxmi Narayan Farsan', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Farsan(1).jpg'},
    {'name': 'Mix Farsan', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Farsan(2).jpg'},
    {'name': 'Speical Farsan', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Farsan(3).jpg'},
    {'name': 'Chitale Farsan', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Farsan(4).jpg'},
    {'name': 'Gathiya', 'price': 35, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Gathiya.jpg'},
    {'name': 'Kurkure', 'price': 20, 'unit': '100g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Kurkure.jpg'},
    {'name': 'Kurkure Solidmasti', 'price': 20, 'unit': '100g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Kurkure(1).jpg'},
    {'name': 'Kurkure Popcorn', 'price': 20, 'unit': '100g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Kurkure(2).jpg'},
    {'name': 'Masala Moong Dal', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Masala Moong Dal.jpg'},
    {'name': 'Masala Peanuts', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Masala Peanutss.jpg'},
    {'name': 'Mixed Dry Nuts', 'price': 99, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Mixed Dry Nuts.jpg'},
    {'name': 'Mixed Dry Nuts with Spices', 'price': 110, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Mixed Dry Nuts with Spices.jpg'},
    {'name': 'Moong Dal', 'price': 35, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Moong Dal.jpg'},
    {'name': 'Moong Dal Blue', 'price': 35, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Moong Dal(1).jpg'},
    {'name': 'Murukku', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Murukku.jpg'},
    {'name': 'Namkeen Mix & Corn Snacks', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Namkeen Mix & Corn Snacks.jpg'},
    {'name': 'Namkeen Mix Bitaji', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Namkeen Mix & Corn Snacks(1).jpg'},
    {'name': 'Namkeen Mix Haldiram', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Namkeen Mix & Corn Snacks(2).jpg'},
    {'name': 'Poha Chivda', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Poha chivda.png'},
    {'name': 'Lays', 'price': 20, 'unit': '100g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Potato Chips.jpg'},
    {'name': 'Ring 91', 'price': 20, 'unit': '100g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Ring 91).jpg'},
    {'name': 'Ring', 'price': 20, 'unit': '100g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Ring.jpg'},
    {'name': 'Roasted Chana', 'price': 30, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Roasted Chana.jpg'},
    {'name': 'Mora Sev', 'price': 25, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Sev.jpg'},
    {'name': 'Nylon Sev', 'price': 25, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Sev(1).jpg'},
    {'name': 'Fine Sev', 'price': 25, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Sev(2).png'},
    {'name': 'Soy Nuts', 'price': 40, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Soy Nuts.png'},
    {'name': 'Spicy Almonds', 'price': 99, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Spicy almonds.png'},
    {'name': 'BTW Spicy Almonds', 'price': 99, 'unit': '200g', 'category': 'Namkeen', 'image': 'assets/images/Namkeen/Spicy almonds(1).png'},
    // --- Wafers ---
    {'name': 'Banana Wafers', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Banana Wafers.jpg'},
    {'name': 'Yellow Banana Wafers', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Banana Wafers(1).png'},
    {'name': 'Salt Banana Wafers', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Banana Wafers(2).png'},
    {'name': 'Masala Bingo Mad Angles', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips.jpg'},
    {'name': 'Achaari Bingo Mad Angles', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips(1).jpg'},
    {'name': 'Bingo Mad Angles masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips(3).jpg'},
    {'name': 'Bingo Mad Angles', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips(4).jpg'},
    {'name': 'Cheese & Cream', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Cheese & Cream.jpg'},
    {'name': 'Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Cheese Balls.png'},
    {'name': 'Victory Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(1).png'},    {'name': 'Smark Snacks Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(2).png'},
    {'name': 'PeppyCheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(3).jpg'},
    {'name': 'Jackpot Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(4).png'},    {'name': 'Kurkure Chilli Chatka', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Chilli Chatka.png'},
    {'name': 'Lays Classic Salted Plain Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips.jpg'},
    {'name': 'Chipsona Classic Salted Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips(1).png'},
    {'name': 'Parle Classic Salted Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips(2).jpg'},
    {'name': 'Corn Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Corn chips.jpg'},
    {'name': 'Lays Magic Masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Magic Masala(3).png'},
    {'name': 'Doritos Nacho Cheese', 'price': 30, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Nacho Cheese.png'},
    {'name': 'Lays Sour Cream & Onion', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Sour Cream & Onion(3).jpg'},
    {'name': 'Tangy Masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Tangy Masala.png'},

    // --- Ketchup ---
    {'name': 'Banana Ketchup', 'price': 60, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Banana Ketchup.jpg'},
    {'name': 'Chili Garlic Ketchup', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Chili Garlic Ketchup.jpg'},
    {'name': 'Kissan Ketchup', 'price': 60, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/ketchup(1).jpg'},
    {'name': 'Kissan Fresh Tomato', 'price': 65, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Kissan Fresh Tomato Ketchup.jpg'},
    {'name': 'Maggi Tomato Ketchup', 'price': 70, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Maggi Tomato Ketchup.jpg'},
    {'name': 'Heinz Organic Tomato Ketchup', 'price': 120, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Organic Tomato Ketchup.jpg'},
    {'name': 'Veeba Chef Special Tomato', 'price': 85, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Veeba Chefs Special Ketchup.png'},

    // --- Shampoo ---
    {'name': 'Clinic Plus', 'price': 99, 'unit': '175ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/clinic plus.jpg'},
    {'name': 'Dove Shampoo', 'price': 170, 'unit': '180ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Dove.png'},
    {'name': 'Head & Shoulders', 'price': 180, 'unit': '180ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/head & shoulders.jpg'},
    {'name': 'Himalaya Shampoo', 'price': 130, 'unit': '200ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Himalaya-shampoo.jpg'},
    {'name': 'Indulekha', 'price': 299, 'unit': '200ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Indulekha.jpg'},
    {'name': 'LOreal', 'price': 350, 'unit': '175ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Loreal.jpg'},
    {'name': 'Pantene', 'price': 220, 'unit': '180ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/pantene hair science.jpg'},
    {'name': 'Patanjali Shampoo', 'price': 80, 'unit': '200ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Patanjali.png'},
    {'name': 'Sunsilk', 'price': 160, 'unit': '180ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/sunsilk hair.png'},
    {'name': 'TRESemme', 'price': 280, 'unit': '185ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Tresemme.png'},

    // --- Soap ---
    {'name': 'Cinthol', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Cinthol.jpg'},
    {'name': 'Dettol Soap', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dettol.jpg'},
    {'name': 'Dove Soap', 'price': 55, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dove.jpg'},
    {'name': 'Himalaya Herbal', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Himalaya Herbal.jpg'},
    {'name': 'Lux Soap', 'price': 45, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Lux.jpg'},
    {'name': 'Medimix', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix.jpg'},
    {'name': 'Patanjali Soap', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Patanjali.jpg'},
    {'name': 'Santoor', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Santoor(1).jpg'},

    // --- Personal Care ---
    {'name': 'Axe Deo', 'price': 199, 'unit': '150ml', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Axe.png'},
    {'name': 'Colgate', 'price': 89, 'unit': '200g', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Colgate.png'},
    {'name': 'Dettol Handwash', 'price': 99, 'unit': '200ml', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Dettol.png'},
    {'name': 'Dove Body Wash', 'price': 150, 'unit': '200ml', 'category': 'Personal Care', 'image': 'assets/images/personal use items/dove.png'},
    {'name': 'Gillette Guard', 'price': 50, 'unit': '1 pc', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Gillete Guard.jpg'},
    {'name': 'NIVEA Body Lotion', 'price': 220, 'unit': '150ml', 'category': 'Personal Care', 'image': 'assets/images/personal use items/NIVEA.jpg'},
    {'name': 'Oral-B Brush', 'price': 99, 'unit': '1 pc', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Oral-B.jpg'},
    {'name': 'Surf Excel', 'price': 55, 'unit': '500g', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Surf excel.png'},

    // --- Pickle ---
    {'name': 'Amla Pickle', 'price': 80, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Amla Pickle.jpg'},
    {'name': 'Mango Pickle', 'price': 80, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mango Pickle.png'},
    {'name': 'Lemon Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Lemon Pickle.jpg'},
    {'name': 'Garlic Pickle', 'price': 90, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Garlic Pickle.jpg'},
    {'name': 'Green Chilli Pickle', 'price': 75, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Green Chilli Pickle.png'},
    {'name': 'Chicken Pickle', 'price': 150, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Chicken Pickle.jpg'},

    // --- Puja Items ---
    {'name': 'Bell (Ghanti)', 'price': 150, 'unit': '1 pc', 'category': 'Puja Items', 'image': 'assets/images/puja items/Bell (Ghanti).jpg'},    {'name': 'Brass Pooja Thali', 'price': 299, 'unit': '1 set', 'category': 'Puja Items', 'image': 'assets/images/puja items/Brass Pooja Thali Set.png'},
    {'name': 'Camphor', 'price': 50, 'unit': '100g', 'category': 'Puja Items', 'image': 'assets/images/puja items/Camphor Karpoor Round.jpg'},
    {'name': 'Agarbatti', 'price': 50, 'unit': '1 pack', 'category': 'Puja Items', 'image': 'assets/images/puja items/mangaldeep rose puja agarbati.png'},
    {'name': 'Diya (Lamp)', 'price': 50, 'unit': '1 pc', 'category': 'Puja Items', 'image': 'assets/images/puja items/Diva ( lamp ).jpg'},
    {'name': 'Kumkum', 'price': 30, 'unit': '50g', 'category': 'Puja Items', 'image': 'assets/images/puja items/kumkum.png'},

    // --- Toys ---
    {'name': 'Barbie Doll', 'price': 599, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Barbie Doll.png'},
    {'name': 'Board Game', 'price': 499, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Board GameHasbro.png'},
    {'name': 'Building Blocks', 'price': 799, 'unit': '1 set', 'category': 'Toys', 'image': 'assets/images/toys items/Building Blocks.png'},
    {'name': 'Hot Wheels', 'price': 299, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels.jpg'},
    {'name': 'Nerf Blaster', 'price': 899, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Nerf Blaster.jpg'},
    {'name': 'Teddy Bear', 'price': 499, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Teddy BearHamleys.png'},
    {'name': 'Hot Wheels F1', 'price': 199, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels F1.jpg'},
    {'name': 'Hot Wheels Batman', 'price': 249, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels Batman.jpg'},
    {'name': 'Hot Wheels 5 Pack', 'price': 499, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels 5.jpg'},
    {'name': 'Nissan Skyline Toy', 'price': 299, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Nissan Skyline.jpg'},    {'name': 'Quad Bike Toy', 'price': 349, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Quad Bike.jpg'},
    {'name': 'Hot Wheels 52 Pack', 'price': 599, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels 52.jpg'},

    // --- Clothes ---
      {'name': 'Alfaq Tshirt', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Alfaq Tshirt.png'},
      {'name': 'Black full sleeves', 'price': 599, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Black full sleeves.png'},
      {'name': 'Black jeans womens', 'price': 899, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Black jeans womens.png'},
      {'name': 'Black jeans', 'price': 899, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Black jeans.png'},
      {'name': 'Blue jeans', 'price': 999, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Blue jeans.png'},
      {'name': 'Blue Sleeveless Denim', 'price': 799, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Blue Sleeveless Denim.png'},
      {'name': 'Blue tshirt', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Blue tshirt.png'},
      {'name': 'Brown tshirt', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Brown tshirt.png'},
      {'name': 'ChrisCross Black Cotton T-Shirt', 'price': 349, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/ChrisCrossBlackCottonT-Shirt.png'},
      {'name': 'Green Floral Dress', 'price': 1199, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Green Floral Dress.png'},
      {'name': '3 Sando', 'price': 199, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/3 Sando.jpg'},
      {'name': 'Green Tshirt', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Green Tshirt.png'},
      {'name': 'Grey full sleeves', 'price': 499, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/grey Full sleeves.png'},
      {'name': 'Full sleeve Tshirt', 'price': 499, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Full sleeve Tshirt.png'},
      {'name': 'Grey tshirts', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Grey tshirts.png'},
      {'name': 'Jacket', 'price': 1499, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Jacket.jpg'},
      {'name': 'Light Blue tshirts', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Light Blue tshirts.jpg'},
      {'name': 'Mens tshirt', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Mens tshirt.png'},
      {'name': 'Monkey Tshirt', 'price': 399, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Monkey Tshirt.png'},
      {'name': 'Printed round neck sublimation', 'price': 399, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/printed-round-neck-sublimation.png'},
      {'name': 'Purple Women Tshirt', 'price': 349, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Purple Women.png'},
      {'name': 'Tshirt RED', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Tshirt RED.png'},
      {'name': 'White full sleeves', 'price': 499, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/White full sleeves.png'},
      {'name': 'White Oversized Tshirt', 'price': 399, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/White_S_Oversized_T-shirt.png'},
      {'name': 'Women Floral Dress', 'price': 1199, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Women Floral Dress.png'},
      {'name': 'Yellow Tshirt', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Yellow Tshirt.png'},
      {'name': 'Black and Grey Tshirts', 'price': 299, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Black and Grey Tshirts.png'},
      {'name': 'Blue and red Tshirt', 'price': 399, 'unit': '1 pc', 'category': 'Clothes', 'image': 'assets/images/cloths items/Blue and red Tshirt.png'},

  ];

  Widget _buildImage(String imagePath, {double height = 110}) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          final pngPath = imagePath.replaceAll('.jpg', '.png');
          if (pngPath != imagePath) {
            return Image.asset(
              pngPath,
              height: height,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                height: height,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            );
          }
          return Container(
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imagePath,
        height: height,
        width: double.infinity,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFF0C831F), size: 14),
                Text('Delivery in 10 minutes',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface, size: 14),
                Text('Mumbai, Maharashtra',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold)),
                Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const NotificationListScreen())),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('${cart.cartCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Search groceries, snacks...',
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // Banner Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 3),
                viewportFraction: 0.92,
              ),
              items: _banners.map((banner) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: banner['image'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: banner['color']),
                        errorWidget: (context, url, error) =>
                            Container(color: banner['color']),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            banner['color'].withOpacity(0.8),
                            Colors.transparent
                          ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(banner['title'],
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(banner['subtitle'],
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // New Blinkit/Instamart-style category navigation
            const HomeCategorySections(),

            _buildPromoBanner(),

            // Product Sections — Offers 3 sections ke baad
            _buildProductSection('🍎 Fresh Fruits', 'Fruits'),
            _buildProductSection('🍦 Ice Creams', 'Ice Creams'),
            _buildProductSection('🍫 Chocolate', 'Chocolate'),

            // ✅ Coupons & Offers — 3 sections ke baad
            _buildOffersSection(),

            // ✅ Events this week — Offers ke baad
            _buildEventsSection(),

            _buildProductSection('🍟 Snacks', 'Snacks'),
            _buildProductSection('🥤 Beverages', 'Beverages'),
            _buildProductSection('🥪 Biscuits', 'Biscuits'),
            _buildProductSection('🥜 Namkeen', 'Namkeen'),
            _buildProductSection('🥔 Wafers', 'Wafers'),
            _buildProductSection('🥤 Cold Drinks', 'Cold Drinks'),
            _buildProductSection('🍅 Ketchup', 'Ketchup'),

            // ✅ Auto-sliding promo banner — Ketchup ke baad
            _buildSlidingPromoSection(),

            _buildProductSection('🧴 Shampoo', 'Shampoo'),
            _buildProductSection('🧼 Soap', 'Soap'),
            _buildProductSection('💄 Personal Care', 'Personal Care'),
            _buildProductSection('🥒 Pickle', 'Pickle'),
            _buildProductSection('🪔 Puja Items', 'Puja Items'),
            _buildProductSection('🧸 Toys', 'Toys'),
            _buildProductSection('👕 Clothes', 'Clothes'),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()));
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
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
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
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(
                                '${cart.cartCount} item${cart.cartCount > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(width: 18),
                        const Icon(Icons.chevron_right,
                            color: Colors.white, size: 22),
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

  // Small overlapping circular thumbnails of items currently in the cart,
  // shown on the "View cart" pill.
  Widget _buildCartThumbnails(CartProvider cart) {
    final items = cart.cartItems.values.take(2).toList();
    return SizedBox(
      width: items.length > 1 ? 54 : 40,
      height: 40,
      child: Stack(
        children: [
          for (int i = 0; i < items.length; i++)
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
                  child: _buildImage(items[i].image, height: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Coupons & Offers Section
  Widget _buildOffersSection() {
    final List<Map<String, dynamic>> offers = [
      {'amount': '₹50 OFF', 'min': 'above ₹599', 'color': const Color(0xFF4CAF50)},
      {'amount': '₹100 OFF', 'min': 'above ₹1199', 'color': const Color(0xFF4CAF50)},
      {'amount': '₹150 OFF', 'min': 'above ₹1799', 'color': const Color(0xFF4CAF50)},
      {'amount': '₹200 OFF', 'min': 'above ₹2399', 'color': const Color(0xFF4CAF50)},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Text('�� Coupons & Offers',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: offer['color'].withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: offer['color'].withOpacity(0.5), width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_rounded,
                        color: offer['color'], size: 22),
                    const SizedBox(height: 4),
                    Text('FLAT',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey[600])),
                    Text(offer['amount'],
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    Text(offer['min'],
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ✅ Events this week Section
  Widget _buildEventsSection() {
    final List<Map<String, dynamic>> events = [
      {
        'title': 'Saffola Oats Recipes',
        'badge': 'ENDING SOON!',
        'image': 'https://images.unsplash.com/photo-1517244683847-7456b63c5969?w=600',
        'logo': 'https://images.unsplash.com/photo-1608500218807-8f9a5dfa2a6a?w=100',
      },
      {
        'title': 'Dabur Hommade Rec...',
        'badge': null,
        'image': 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=600',
      },
      {
        'title': 'Dark Cocoa Affair',
        'badge': 'ENDING SOON!',
        'image': 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=600',
      },
    ];

    Widget eventCard(Map<String, dynamic> event, {double height = 96}) {
      return Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(
            image: CachedNetworkImageProvider(event['image']),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            if (event['badge'] != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(event['badge'],
                      style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Text(event['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Events this week',
              style:
                  GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: eventCard(events[0], height: 200)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      eventCard(events[1], height: 96),
                      eventCard(events[2], height: 96),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CategoryModel? _findCategoryById(String id) {
    for (final section in CategoryMockData.sections) {
      for (final cat in section.categories) {
        if (cat.id == id) return cat;
      }
    }
    return null;
  }

  Widget _promoTile(String categoryId, String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        final category = _findCategoryById(categoryId);
        if (category != null) {
          CategoryNavRoutes.openCategory(context, category);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF3DC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock up your kitchen!',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Fresh groceries, snacks & essentials, delivered fast',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              SizedBox(
                width: 64,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.shopping_basket, size: 48, color: const Color(0xFF0C831F)),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(Icons.local_grocery_store, size: 26, color: const Color(0xFFE0592A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _promoTile('cat_veg_fruits', 'Fruits & Vegetables', Icons.eco, const Color(0xFF3AA655)),
              _promoTile('cat_dairy_bread_eggs', 'Dairy, Bread & Eggs', Icons.egg_alt, const Color(0xFF2F8FD1)),
              _promoTile('cat_chips_namkeen', 'Chips & Namkeen', Icons.fastfood, const Color(0xFFE0A72A)),
              _promoTile('cat_cleaners_repellents', 'Cleaners & Repellents', Icons.cleaning_services, const Color(0xFF2F7FC1)),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Auto-sliding Promo Banner Section
  final List<Map<String, dynamic>> _slidingPromos = [
    {
      'title': 'Herbal Living',
      'subtitle': 'Support your everyday wellness with herbs',
      'image': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800',
      'bgColor': Color(0xFFF3ECE0),
      'textColor': Colors.black,
    },
    {
      'title': 'Dark Cocoa Affair',
      'subtitle': 'Enjoy a bite of your favourite dark chocolate',
      'image': 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=800',
      'bgColor': Color(0xFF241208),
      'textColor': Colors.white,
    },
    {
      'title': '1 year of CeraVe on Blinkit!',
      'subtitle': 'Dermat recommended skincare routine',
      'image': 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=800',
      'bgColor': Color(0xFF9DA3A6),
      'textColor': Colors.white,
    },
    {
      'title': 'Up to 70% OFF on bags',
      'subtitle': 'Get laptop bags, tote bags & more',
      'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800',
      'bgColor': Color(0xFFEDE3C8),
      'textColor': Colors.black,
    },
  ];

  Widget _buildSlidingPromoSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          enlargeCenterPage: true,
          autoPlayInterval: const Duration(seconds: 3),
          viewportFraction: 0.88,
        ),
        items: _slidingPromos.map((promo) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: promo['bgColor'],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 220,
                    child: CachedNetworkImage(
                      imageUrl: promo['image'],
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const SizedBox(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(promo['title'],
                                style: GoogleFonts.poppins(
                                    color: promo['textColor'],
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 170,
                              child: Text(promo['subtitle'],
                                  style: GoogleFonts.poppins(
                                      color: promo['textColor'].withOpacity(0.75),
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: promo['textColor'] == Colors.white
                                ? Colors.white
                                : Colors.black,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text('Shop now',
                              style: GoogleFonts.poppins(
                                  color: promo['textColor'] == Colors.white
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductSection(String title, String category) {
    final items = _products.where((p) => p['category'] == category).toList();
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text('See all',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: const Color(0xFF0C831F))),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              final qty =
              context.watch<CartProvider>().getQuantity(product['name']);
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: product,
                      allProducts: items,
                    ),
                  ),
                ),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 36) / 3,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1), blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: _buildImage(product['image']),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'],
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(product['unit'],
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${product['price']}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0C831F))),
                                qty == 0
                                    ? GestureDetector(
                                  onTap: () => context
                                      .read<CartProvider>()
                                      .addToCart(
                                      product['name'],
                                      product['price'],
                                      product['unit'],
                                      product['image']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF0C831F),
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    child: Text('ADD',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.bold)),
                                  ),
                                )
                                    : Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => context
                                          .read<CartProvider>()
                                          .removeFromCart(
                                          product['name']),
                                      child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                              color: const Color(
                                                  0xFF0C831F),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  6)),
                                          child: const Icon(Icons.remove,
                                              color: Colors.white,
                                              size: 16)),
                                    ),
                                    Padding(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: Text('$qty',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.bold))),
                                    GestureDetector(
                                      onTap: () => context
                                          .read<CartProvider>()
                                          .addToCart(
                                          product['name'],
                                          product['price'],
                                          product['unit'],
                                          product['image']),
                                      child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                              color: const Color(
                                                  0xFF0C831F),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  6)),
                                          child: const Icon(Icons.add,
                                              color: Colors.white,
                                              size: 16)),
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
        const SizedBox(height: 8),
      ],
    );
  }
}
