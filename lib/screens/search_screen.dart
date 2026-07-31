import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

enum SortOption { relevance, priceLowHigh, priceHighLow, nameAZ }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowHigh:
        return 'Price: Low to High';
      case SortOption.priceHighLow:
        return 'Price: High to Low';
      case SortOption.nameAZ:
        return 'Name: A to Z';
    }
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  static const _bg = Color(0xFF121212);
  static const _card = Color(0xFF1E1E1E);
  static const _card2 = Color(0xFF2C2C2C);

  final List<Map<String, dynamic>> _allProducts = [
    {'name': 'Hot Wheels', 'price': 299, 'unit': '1 pc', 'image': 'assets/images/toys items/Hot Wheels.jpg'},
    {'name': 'Barbie Doll', 'price': 599, 'unit': '1 pc', 'image': 'assets/images/toys items/Barbie Doll.png'},
    {'name': 'Building Blocks', 'price': 799, 'unit': '1 set', 'image': 'assets/images/toys items/Building Blocks.png'},
    {'name': 'Teddy Bear', 'price': 499, 'unit': '1 pc', 'image': 'assets/images/toys items/Teddy BearHamleys.png'},
    {'name': 'Puzzle Game', 'price': 349, 'unit': '1 pc', 'image': 'assets/images/toys items/Puzzle Game Funskool.jpg'},
    {'name': 'Board Game', 'price': 499, 'unit': '1 pc', 'image': 'assets/images/toys items/Board GameHasbro.png'},
    {'name': 'Educational Toy', 'price': 399, 'unit': '1 pc', 'image': 'assets/images/toys items/Educational Toy Skillmatics.jpg'},
    {'name': 'Marvel Action Figure', 'price': 699, 'unit': '1 pc',  'image': 'assets/images/toys items/Marvel.jpg'},
    {'name': 'Nerf Blaster', 'price': 899, 'unit': '1 pc', 'image': 'assets/images/toys items/Nerf Blaster.jpg'},
    {'name': 'Toy Train Set', 'price': 599, 'unit': '1 set', 'image': 'assets/images/toys items/Toy Train Set Fisher-Price.jpg'},
    {'name': 'Hot Wheels F1', 'price': 199, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels F1.jpg'},
    {'name': 'Hot Wheels Batman', 'price': 249, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels Batman.jpg'},
    {'name': 'Hot Wheels 5 Pack', 'price': 499, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels 5.jpg'},
    {'name': 'Nissan Skyline Toy', 'price': 299, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Nissan Skyline.jpg'},
    {'name': 'Quad Bike Toy', 'price': 349, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Quad Bike.jpg'},
    {'name': 'Hot Wheels 52 Pack', 'price': 599, 'unit': '1 pc', 'category': 'Toys', 'image': 'assets/images/toys items/Hot Wheels 52.jpg'},
    {'name': 'Agarbatti', 'price': 50, 'unit': '1 pack', 'image': 'assets/images/puja items/mangaldeep rose puja agarbati.png'},
    {'name': 'Camphor', 'price': 50, 'unit': '100g', 'image': 'assets/images/puja items/Camphor Karpoor Round.jpg'},
    {'name': 'Diya (Lamp)', 'price': 50, 'unit': '1 pc', 'image': 'assets/images/puja items/Diva ( lamp ).jpg'},
    {'name': 'Haldi', 'price': 40, 'unit': '100g', 'image': 'assets/images/puja items/Haldi (Turmeric).jpg'},
    {'name': 'Kumkum', 'price': 30, 'unit': '50g', 'image': 'assets/images/puja items/kumkum.png'},
    {'name': 'Chandan Paste', 'price': 80, 'unit': '50g', 'image': 'assets/images/puja items/Chandan (sandal paste).jpg'},
    {'name': 'Cotton Batti', 'price': 30, 'unit': '100 pcs', 'image': 'assets/images/puja items/Cotton Batti (Wicks).png'},
    {'name': 'Moli Thread', 'price': 20, 'unit': '1 roll', 'image': 'assets/images/puja items/Moli (sacred thread).png'},
    {'name': 'Bell (Ghanti)', 'price': 150, 'unit': '1 pc', 'image': 'assets/images/puja items/Bell (Ghanti).jpg'},
    {'name': 'Brass Pooja Thali', 'price': 299, 'unit': '1 set', 'image': 'assets/images/puja items/Brass Pooja Thali Set.png'},
    {'name': 'Ghee for Diya', 'price': 99, 'unit': '200g', 'image': 'assets/images/puja items/Ghee (for diya).png'},
    {'name': 'Rice Akshat', 'price': 30, 'unit': '500g', 'image': 'assets/images/puja items/Rice (Akshat).jpg'},
    {'name': 'Sambrani Dhoop', 'price': 60, 'unit': '1 pack', 'image': 'assets/images/puja items/Sambrani Dhoop Sticks.png'},
    {'name': 'Supari', 'price': 40, 'unit': '100g', 'image': 'assets/images/puja items/Supari (betel nut).jpg'},
    {'name': 'Amla Pickle', 'price': 80, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Amla Pickle.jpg'},
    {'name': 'Pahadi Amla Pickle', 'price': 80, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Amla Pickle(1).jpg'},
    {'name': 'Priya Amla Pickle', 'price': 80, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Amla Pickle(2).jpg'},
    {'name': 'Avocado Pickle', 'price': 120, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Avocado Pickle.jpg'},
    {'name': 'Carrot Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Carrot Pickle.jpg'},
    {'name': 'Ruchi Carrot Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Carrot Pickle(2).png'},
    {'name': 'Ram bhandhu Carrot Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Carrot Pickle(3).png'},
    {'name': 'Chicken Pickle', 'price': 150, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Chicken Pickle.jpg'},
    {'name': 'Fish Pickle', 'price': 120, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Fish Pickle.jpg'},
    {'name': 'Double horse Fish Pickle', 'price': 120, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Fish Pickle(1).png'},
    {'name': 'Jayam gold Fish Pickle', 'price': 120, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Fish Pickle(2).jpg'},
    {'name': 'Pawn Fish Pickle', 'price': 120, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Fish Pickle(3).jpg'},
    {'name': 'Garlic Pickle', 'price': 90, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Garlic Pickle.jpg'},
    {'name': 'Ram Bhandhu Garlic Pickle', 'price': 90, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Garlic Pickle(1).jpg'},
    {'name': 'Priya Garlic Pickle', 'price': 90, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Garlic Pickle(2).jpg'},
    {'name': 'Ginger Pickle', 'price': 85, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Ginger Pickle.jpg'},
    {'name': 'Priya Ginger Pickle', 'price': 85, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Ginger Pickle(1).jpg'},
    {'name': 'Aachi Ginger Pickle', 'price': 85, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Ginger Pickle(2).jpg'},
    {'name': 'Mothers Ginger Pickle', 'price': 85, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Ginger Pickle(4).jpg'},
    {'name': 'Green Chilli Pickle', 'price': 75, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Green Chilli Pickle.png'},
    {'name': 'Ram Green Chilli Pickle', 'price': 75, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Green Chilli Pickle(1).png'},
    {'name': 'Mothers Green Chilli Pickle', 'price': 75, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Green Chilli Pickle(2).png'},
    {'name': 'Red Kimchi', 'price': 199, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Kimchi.png'},
    {'name': 'Yellow Kimchi', 'price': 199, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Kimchi(1).jpg'},
    {'name': 'Original Kimchi', 'price': 199, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Kimchi(3).png'},
    {'name': 'Kothimera Pickle', 'price': 90, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Kothimera Pickle (Coriander).jpg'},
    {'name': 'Lemon Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Lemon Pickle.jpg'},
    {'name': 'Aachi Lemon Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Lemon Pickle(1).png'},
    {'name': 'Mango Pickle', 'price': 80, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mango Pickle.png'},
    {'name': 'Mushroom Pickle', 'price': 110, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Masroom Pickle.jpg'},
    {'name': 'Pachranga Mushroom Pickle', 'price': 110, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Masroom Pickle (1).png'},
    {'name': 'Nature Mushroom Pickle', 'price': 110, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Masroom Pickle (2).jpg'},
    {'name': 'Mixed Fruit Pickle', 'price': 95, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mixed Fruit Pickle.jpg'},
    {'name': 'Neeraj Mixed Fruit Pickle', 'price': 95, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mixed Fruit Pickle(1).png'},
    {'name': 'Mothers Mixed Fruit Pickle', 'price': 95, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mixed Fruit Pickle(2).png'},
    {'name': 'Mixed Vegetable Pickle', 'price': 85, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mixed Vegetable Pickle(1).jpg'},
    {'name': 'Mutton Pickle', 'price': 180, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Mutton Pickle.jpg'},
    {'name': 'Onion Pickle', 'price': 75, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Onion Pickle.jpg'},
    {'name': 'Aachi Onion Pickle', 'price': 75, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Onion Pickle(1).jpg'},
    {'name': 'Tomato Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Tomato Pickle.jpg'},
    {'name': 'Priya Tomato Pickle', 'price': 70, 'unit': '500g', 'category': 'Pickle', 'image': 'assets/images/pickel/Tomato Pickle(1).jpg'},
    {'name': 'Axe Deo', 'price': 199, 'unit': '150ml', 'image': 'assets/images/personal use items/Axe.png'},
    {'name': 'Colgate', 'price': 89, 'unit': '200g', 'image': 'assets/images/personal use items/Colgate.png'},
    {'name': 'Dettol Handwash', 'price': 99, 'unit': '200ml', 'image': 'assets/images/personal use items/Dettol.png'},
    {'name': 'Dove Body Wash', 'price': 150, 'unit': '200ml', 'image': 'assets/images/personal use items/dove.png'},
    {'name': 'Gillette Guard', 'price': 50, 'unit': '1 pc', 'image': 'assets/images/personal use items/Gillete Guard.jpg'},
    {'name': 'Himalaya Cream', 'price': 75, 'unit': '50ml', 'image': 'assets/images/personal use items/Himalaya.jpg'},
    {'name': 'NIVEA Body Lotion', 'price': 220, 'unit': '150ml', 'image': 'assets/images/personal use items/NIVEA.jpg'},
    {'name': 'Oral-B Brush', 'price': 99, 'unit': '1 pc', 'image': 'assets/images/personal use items/Oral-B.jpg'},
    {'name': 'Surf Excel', 'price': 55, 'unit': '500g', 'image': 'assets/images/personal use items/Surf excel.png'},
    {'name': 'Vim Bar', 'price': 30, 'unit': '300g', 'image': 'assets/images/personal use items/Vim.jpg'},
    {'name': 'Head & Shoulders PC', 'price': 199, 'unit': '180ml', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Head-Shoulder-Shampoo.jpg'},
    {'name': 'Lux Beauty Bar', 'price': 45, 'unit': '100g', 'category': 'Personal Care', 'image': 'assets/images/personal use items/Lux.png'},
    {'name': 'Cinthol', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Cinthol.jpg'},
    {'name': 'Cinthol Black Deo', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Cinthol(1).jpg'},
    {'name': 'Cinthol Deo', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Cinthol(4).jpg'},
    {'name': 'Dettol Soap', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dettol.jpg'},
    {'name': 'Dettol Original', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dettol (1).jpg'},
    {'name': 'Dettol Cool', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dettol (3).png'},
    {'name': 'Dettol Rose', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dettol (4).png'},
    {'name': 'Dettol Pink', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dettol(2).png'},
    {'name': 'Dove Soap', 'price': 55, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dove.jpg'},
    {'name': 'Dove Serum Bar', 'price': 55, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dove(1).jpg'},
    {'name': 'Dove Sandalwood', 'price': 55, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dove(3).jpg'},
    {'name': 'Dove neem', 'price': 55, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dove(4).png'},
    {'name': 'Dove Cream beauty', 'price': 55, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Dove(20).png'},
    {'name': 'Himalaya Herbal', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Himalaya Herbal.jpg'},
    {'name': 'Himalaya Herbal Neem', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Himalaya Herbal(1).jpg'},
    {'name': 'Himalaya Herbal AlmondRose', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Himalaya Herbal(2).png'},
    {'name': 'Himalaya Herbal Coconuts', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Himalaya Herbal(3).png'},
    {'name': 'Lifeboy', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Lifeboy.png'},
    {'name': 'Lifeboy Blue', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/lifebuoy.jpg'},
    {'name': 'Lux Soap', 'price': 45, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Lux.jpg'},
    {'name': 'Lux Rose', 'price': 45, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Lux(1).png'},
    {'name': 'Lux Jasmine', 'price': 45, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Lux(2).png'},
    {'name': 'Lux Creamy', 'price': 45, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Lux(3).jpg'},
    {'name': 'Medimix', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix.jpg'},
    {'name': 'Medimix Green herb', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix(1).png'},
    {'name': 'Medimix Herb', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix(2).png'},
    {'name': 'Medimix Ayurvedic', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix(3).png'},
    {'name': 'Medimix Transparent', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix(4).png'},
    {'name': 'Medimix Yellow', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix(5).png'},
    {'name': 'Medimix Green', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Medimix(6).jpg'},
    {'name': 'Neem Soap', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Neem Soap.png'},
    {'name': 'Patanjali Soap', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Patanjali.jpg'},
    {'name': 'Patanjali Body cleanser', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Patanjali(1).png'},
    {'name': 'Patanjali Aloevera', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Patanjali(2).jpg'},
    {'name': 'Patanjali Aloevera', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Patanjali(30).png'},
    {'name': 'Pears Blue', 'price': 50, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Pears.jpg'},
    {'name': 'Pears Yellow', 'price': 50, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/pears(2).png'},
    {'name': 'Pears Green', 'price': 50, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/pears(4).png'},
    {'name': 'Santoor Silk', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Santoor.jpg'},
    {'name': 'Santoor', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Santoor(1).jpg'},
    {'name': 'Santoor almond milk', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Santoor(2).png'},
    {'name': 'Santoor Chandan', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Santoor(3).png'},
    {'name': 'Santoor lemon', 'price': 35, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Santoor(4).jpg'},
    {'name': 'Dettol Coldgne', 'price': 40, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Settol (5).png'},
    {'name': 'Tulsi Soap', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Tulsi Soap.png'},
    {'name': 'Himalaya Tulsi', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Tulsi Soap(1).jpg'},
    {'name': 'Tulsi Herbal bar', 'price': 30, 'unit': '100g', 'category': 'Soap', 'image': 'assets/images/Soap/Tulsi Soap(2).jpg'},
    {'name': 'Clinic Plus', 'price': 99, 'unit': '175ml', 'image': 'assets/images/shampoo/clinic plus.jpg'},
    {'name': 'Dove Shampoo', 'price': 170, 'unit': '180ml', 'image': 'assets/images/shampoo/Dove.png'},
    {'name': 'Head & Shoulders', 'price': 180, 'unit': '180ml', 'image': 'assets/images/shampoo/head & shoulders.jpg'},
    {'name': 'Himalaya Shampoo', 'price': 130, 'unit': '200ml', 'image': 'assets/images/shampoo/Himalaya-shampoo.jpg'},
    {'name': 'Pantene', 'price': 220, 'unit': '180ml', 'image': 'assets/images/shampoo/pantene hair science.jpg'},
    {'name': 'Patanjali Shampoo', 'price': 80, 'unit': '200ml', 'image': 'assets/images/shampoo/Patanjali.png'},
    {'name': 'Sunsilk', 'price': 160, 'unit': '180ml', 'image': 'assets/images/shampoo/sunsilk hair.png'},
    {'name': 'TRESemme', 'price': 280, 'unit': '185ml', 'image': 'assets/images/shampoo/Tresemme.png'},
    {'name': 'Indulekha', 'price': 299, 'unit': '200ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Indulekha.jpg'},
    {'name': 'LOreal', 'price': 350, 'unit': '175ml', 'category': 'Shampoo', 'image': 'assets/images/shampoo/Loreal.jpg'},
    {'name': 'Banana Ketchup', 'price': 60, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Banana Ketchup.jpg'},
    {'name': 'Chili Garlic Ketchup', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Chili Garlic Ketchup.jpg'},
    {'name': 'Mastershow Chili Garlic Ketchup', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Chili Garlic Ketchup(1).jpg'},
    {'name': 'Chili Garlic Ketchup Spicy', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Chili Garlic Ketchup(3).jpg'},
    {'name': 'Kisssan Chili Garlic Ketchup', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Chili Garlic Ketchup(4).jpg'},
    {'name': 'Garlic Ketchup', 'price': 75, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Garlic Ketchup.jpg'},
    {'name': 'Heinz Garlic Ketchup', 'price': 75, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Garlic Ketchup(1).jpg'},
    {'name': 'Garlic Ketchup Shangrila', 'price': 75, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Garlic Ketchup(2).jpg'},
    {'name': 'Hot & Sweet Ketchup', 'price': 70, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Hot & Sweet Ketchup.jpg'},
    {'name': 'Hot & Sweet Ketchup(1)', 'price': 70, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Hot & Sweet Ketchup(1).jpg'},
    {'name': 'Hot & Sweet Ketchup Packet', 'price': 70, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Hot & Sweet Ketchup(2).jpg'},
    {'name': 'Ketchup', 'price': 60, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/ketchup.jpg'},
    {'name': 'Kissan Ketchup', 'price': 60, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/ketchup(1).jpg'},
    {'name': 'Kissan Fresh Tomato', 'price': 65, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Kissan Fresh Tomato Ketchup.jpg'},
    {'name': 'Kissan Fresh Tomato Bottle', 'price': 65, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Kissan Fresh Tomato Ketchup(1).jpg'},
    {'name': 'Maggi Tomato Ketchup', 'price': 70, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Maggi Tomato Ketchup.jpg'},
    {'name': 'No Added Sugar Ketchup', 'price': 90, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/No Added Sugar Ketchup.jpg'},
    {'name': 'Heinz No Added Sugar Ketchup', 'price': 90, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/No Added Sugar Ketchup(1).jpg'},
    {'name': 'Veeba No Added Sugar Ketchup', 'price': 90, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/No Added Sugar Ketchup(2).jpg'},
    {'name': 'Onion Ketchup', 'price': 75, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Onion Ketchup.jpg'},
    {'name': 'Heinz Onion Ketchup ', 'price': 75, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Onion Ketchup(1).jpg'},
    {'name': 'Sweet Onion Ketchup', 'price': 75, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Onion Ketchup(2).jpg'},
    {'name': 'Heinz Organic Tomato Ketchup', 'price': 120, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Organic Tomato Ketchup.jpg'},
    {'name': 'Organic Tomato Ketchup', 'price': 120, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Organic Tomato Ketchup(1).jpg'},
    {'name': 'Peri-Peri Ketchup', 'price': 90, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Peri-Peri Ketchup.jpg'},
    {'name': 'Veeba Peri-Peri Ketchup', 'price': 90, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Peri-Peri Ketchup(1).jpg'},
    {'name': 'Smoky BBQ Ketchup', 'price': 95, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Smoky BBQ Ketchup.jpg'},
    {'name': 'Heinz Smoky BBQ Ketchup', 'price': 95, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Smoky BBQ Ketchup(1).jpg'},
    {'name': 'Masterfood Smoky BBQ Ketchup', 'price': 95, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Smoky BBQ Ketchup(2).jpg'},
    {'name': 'Sweet & Sour Ketchup', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Sweet & Sour Ketchup.jpg'},
    {'name': 'Sweet & Sour Ketchup Spicy', 'price': 80, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Sweet & Sour Ketchup(1).jpg'},
    {'name': 'Veeba Chef Special Tomato', 'price': 85, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Veeba Chefs Special Ketchup.png'},
    {'name': 'Veeba Chef Special Hot Sweet', 'price': 85, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Veeba Chefs Special Ketchup(1).png'},
    {'name': 'Veeba Chef Special Tomato', 'price': 85, 'unit': '500g', 'category': 'Ketchup', 'image': 'assets/images/ketchup/Veeba Chefs Special Ketchup(3).png'},
    {'name': 'Banana Wafers', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Banana Wafers.jpg'},
    {'name': 'Yellow Banana Wafers', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Banana Wafers(1).png'},
    {'name': 'Salt Banana Wafers', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Banana Wafers(2).png'},
    {'name': 'Masala Bingo Mad Angles', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips.jpg'},
    {'name': 'Achaari Bingo Mad Angles', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips(1).jpg'},
    {'name': 'Bingo Mad Angles masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips(3).jpg'},
    {'name': 'Bingo Mad Angles', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Bingo Mad Angles Masala Chips(4).jpg'},
    {'name': 'Cheese & Cream', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Cheese & Cream.jpg'},
    {'name': 'Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Cheese Balls.png'},
    {'name': 'Victory Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(1).png'},
    {'name': 'Smark Snacks Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(2).png'},
    {'name': 'PeppyCheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(3).jpg'},
    {'name': 'Jackpot Cheese Balls', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/cheese balls(4).png'},
    {'name': 'Kurkure Chilli Chatka', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Chilli Chatka.png'},
    {'name': 'Kurkure Chilli Chatka', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Chilli Chatka(1).jpg'},
    {'name': 'Lays Classic Salted Plain Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips.jpg'},
    {'name': 'Chipsona Classic Salted Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips(1).png'},
    {'name': 'Parle Classic Salted Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips(2).jpg'},
    {'name': 'Chhedas Classic Salted Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips(3).png'},
    {'name': 'Classic Salted Chips Yellow', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Classic Salted  Plain Chips(4).png'},
    {'name': 'Corn Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Corn chips.jpg'},
    {'name': 'Khushhal Corn Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Corn chips(1).jpg'},
    {'name': 'Corn munch Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Corn chips(2).png'},
    {'name': 'Yellow Corn Chips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Corn chips(3).jpg'},
    {'name': 'Pringles Desi Masala Tadka', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Desi Masala Tadka.png'},
    {'name': 'Balaji Magic Masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Magic Masala.png'},
    {'name': 'Diamond Magic Masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Magic Masala(2).png'},
    {'name': 'Lays Magic Masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Magic Masala(3).png'},
    {'name': 'Doritos Nacho Cheese', 'price': 30, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Nacho Cheese.png'},
    {'name': 'Nacho Cheese', 'price': 30, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Nacho Cheese(1).png'},
    {'name': 'Doritos Nacho Cheese', 'price': 30, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Nacho Cheese(2).jpg'},
    {'name': 'Nacho Cheese Creamy', 'price': 30, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Nacho Cheese(3).png'},
    {'name': 'Nacho Cheese', 'price': 30, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Nacho Cheese(4).jpg'},
    {'name': 'Haldiram Sour Cream & Onion', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Sour Cream & Onion.jpg'},
    {'name': 'Pringles Sour Cream & Onion', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Sour Cream & Onion(1).png'},
    {'name': 'Balaji Sour Cream & Onion', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Sour Cream & Onion(2).png'},
    {'name': 'Lays Sour Cream & Onion', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Sour Cream & Onion(3).jpg'},
    {'name': 'Lays Sour Cream & Onion', 'price': 25, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Sour Cream & Onion(4).png'},
    {'name': 'Tangy Masala', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Tangy Masala.png'},
    {'name': 'Tangy Masala Garden', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Tangy Masala(1).png'},
    {'name': 'Tangy Masala Tomato', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Tangy Masala(2).png'},
    {'name': 'Tangy Masala Funflips', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Tangy Masala(3).png'},
    {'name': 'Tangy Masala Haldiram', 'price': 20, 'unit': '100g', 'category': 'Wafers', 'image': 'assets/images/Wafers/Tangy Masala(4).png'},
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
    {'name': 'Parle-G', 'price': 10, 'unit': '100g', 'image': 'assets/images/Biscuits/parleG.jpg'},
    {'name': 'Bourbon', 'price': 20, 'unit': '100g', 'image': 'assets/images/Biscuits/Bourbon.jpg'},
    {'name': 'Marie', 'price': 25, 'unit': '200g', 'image': 'assets/images/Biscuits/Marie.jpg'},
    {'name': 'KrackJack', 'price': 20, 'unit': '100g', 'image': 'assets/images/Biscuits/KrackJack.jpg'},
    {'name': 'Good Day', 'price': 30, 'unit': '150g', 'image': 'assets/images/Biscuits/Good Day.jpg'},
    {'name': 'Dark Fantasy', 'price': 50, 'unit': '100g', 'image': 'assets/images/Biscuits/Dark Fantasy Choco Fills.jpg'},
    {'name': 'Hide & Seek', 'price': 30, 'unit': '100g', 'image': 'assets/images/Biscuits/Hide & Seek.jpg'},
    {'name': 'Milk Bikis', 'price': 20, 'unit': '100g', 'image': 'assets/images/Biscuits/Milk Bikis.jpg'},
    {'name': 'Nice', 'price': 15, 'unit': '100g', 'image': 'assets/images/Biscuits/Nice.jpg'},
    {'name': 'Tiger', 'price': 20, 'unit': '100g', 'image': 'assets/images/Biscuits/Tiger.jpg'},
    {'name': 'Treat', 'price': 30, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Treat.jpg'},
    {'name': 'Butter Biscuit', 'price': 25, 'unit': '100g', 'category': 'Biscuits', 'image': 'assets/images/Biscuits/Butter.jpg'},
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
    {'name': 'Magnum Almond', 'price': 110, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum Almond.png'},
    {'name': 'Magnum Chocolate', 'price': 110, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum Chocolate.png'},
    {'name': 'Magnum Dark Chocolate', 'price': 120, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum dark chocolate.png'},
    {'name': 'Magnum Ice Cream', 'price': 110, 'unit': '1 pc', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Magnum ice cream.png'},
    {'name': 'Sweet Delicious Oreo', 'price': 140, 'unit': '1 tub', 'category': 'Ice Creams', 'image': 'assets/images/Ice Creams/Sweet-delicious oreo.jpg'},
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
    {'name': 'Amul Chocolate Milk', 'price': 40, 'unit': '200ml', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/amul_chocolate_milk.jpg'},
    {'name': '5 Star Chocolate', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate', 'image': 'assets/images/Chocolate/cadbury_5star.jpg'},
    {'name': 'Dairy Milk Small', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate','image': 'assets/images/Chocolate/dairy_milk_small.jpg'},
    {'name': 'Dairy Milk', 'price': 10, 'unit': '1 pc', 'category': 'Chocolate','image': 'assets/images/Chocolate/Dairy_milk.png'},
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
    {'name': 'Apple', 'price': 120, 'unit': '4 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/Apple.png'},
    {'name': 'Banana', 'price': 40, 'unit': '6 pcs', 'category': 'Fruits', 'image': 'assets/images/Fruits/banana.png'},
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
  ];

  String? _selectedCategory;
  SortOption _sortOption = SortOption.relevance;

  List<Map<String, dynamic>> get _searchMatches => _query.isEmpty
      ? []
      : _allProducts.where((p) =>
  p['name'].toString().toLowerCase().contains(_query.toLowerCase()) ||
      p['category'].toString().toLowerCase().contains(_query.toLowerCase())
  ).toList();

  List<String> get _matchingCategories {
    final cats = _searchMatches
        .map((p) => p['category']?.toString())
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  List<Map<String, dynamic>> get _filtered {
    var results = _searchMatches;

    if (_selectedCategory != null) {
      results = results.where((p) => p['category']?.toString() == _selectedCategory).toList();
    }

    results = List<Map<String, dynamic>>.from(results);
    switch (_sortOption) {
      case SortOption.priceLowHigh:
        results.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case SortOption.priceHighLow:
        results.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
      case SortOption.nameAZ:
        results.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case SortOption.relevance:
        break;
    }
    return results;
  }

  final List<String> _popular = [
    'Biscuits', 'Chips', 'Shampoo', 'Soap', 'Cold Drinks', 'Namkeen', 'Pickle', 'Puja Items'
  ];

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 120, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 120, color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imagePath,
      height: 120, width: double.infinity, fit: BoxFit.cover,
      placeholder: (_, __) => Container(height: 120, color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      errorWidget: (_, __, ___) => Container(height: 120, color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (val) => setState(() {
            _query = val;
            _selectedCategory = null;
          }),
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Search groceries...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.black87),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _query = '';
                  _selectedCategory = null;
                });
              },
            )
                : null,
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildPopularSearches()
          : _filtered.isEmpty
          ? _buildNoResults()
          : _buildResults(),
    );
  }

  Widget _buildPopularSearches() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Searches',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _popular.map((item) {
              return GestureDetector(
                onTap: () {
                  _controller.text = item;
                  setState(() {
                    _query = item;
                    _selectedCategory = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(item, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No results for "$_query"',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Try searching something else',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Sort By', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...SortOption.values.map((opt) => ListTile(
                title: Text(opt.label, style: GoogleFonts.poppins(fontSize: 13)),
                trailing: _sortOption == opt
                    ? const Icon(Icons.check, color: Color(0xFF0C831F))
                    : null,
                onTap: () {
                  setState(() => _sortOption = opt);
                  Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSortBar() {
    final categories = _matchingCategories;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All', style: GoogleFonts.poppins(fontSize: 12)),
                    selected: _selectedCategory == null,
                    selectedColor: const Color(0xFFEAF7EA),
                    labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _selectedCategory == null ? const Color(0xFF0C831F) : Colors.black87,
                        fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal),
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(cat, style: GoogleFonts.poppins(fontSize: 12)),
                      selected: _selectedCategory == cat,
                      selectedColor: const Color(0xFFEAF7EA),
                      labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _selectedCategory == cat ? const Color(0xFF0C831F) : Colors.black87,
                          fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 16, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text('Sort', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final cart = context.watch<CartProvider>();
    return Column(
      children: [
        _buildFilterSortBar(),
        Expanded(child: _buildResultsGrid(cart)),
      ],
    );
  }

  Widget _buildResultsGrid(CartProvider cart) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final product = _filtered[index];
        final qty = cart.getQuantity(product['name']);
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildImage(product['image']),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'],
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(product['unit'],
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${product['price']}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.bold,
                                color: const Color(0xFF0C831F))),
                        qty == 0
                            ? GestureDetector(
                          onTap: () => context.read<CartProvider>().addToCart(
                              product['name'], product['price'],
                              product['unit'], product['image']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFF0C831F),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('ADD',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        )
                            : Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.read<CartProvider>().removeFromCart(product['name']),
                              child: Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF0C831F),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.remove, color: Colors.white, size: 14)),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text('$qty',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
                            GestureDetector(
                              onTap: () => context.read<CartProvider>().addToCart(
                                  product['name'], product['price'],
                                  product['unit'], product['image']),
                              child: Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF0C831F),
                                      borderRadius: BorderRadius.circular(6)),
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
        );
      },
    );
  }
}