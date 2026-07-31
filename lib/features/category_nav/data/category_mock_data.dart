import 'package:flutter/material.dart';
import '../../../constants/asset_constants.dart';
import '../models/category_models.dart';

/// Static mock dataset for the home category-navigation module.
/// No backend/API calls — [CategoryRepository] reads from this file and
/// wraps it in Futures to simulate network latency.
class CategoryMockData {
  CategoryMockData._();

  static final List<CategorySectionModel> sections = _buildSections();

  static List<ProductModel> get allProducts =>
      sections.expand((s) => s.categories).expand((c) => _productsFor(c)).toList();

  static List<CategorySectionModel> _buildSections() {
    return [
      CategorySectionModel(
        id: 'sec_grocery',
        title: 'Grocery & Kitchen',
        categories: [
          _category('cat_veg_fruits', 'Vegetables & Fruits', 'sec_grocery',
              Icons.eco, const Color(0xFF3AA655),
              ['Fresh Vegetables', 'Fresh Fruits', 'Organic Produce', 'Exotic Fruits'],
              image: AssetConstants.vegetablesFruits),
          _category('cat_atta_rice_dal', 'Atta, Rice & Dal', 'sec_grocery',
              Icons.grain, const Color(0xFFC08A3E),
              ['Atta & Flours', 'Rice & Rice Products', 'Dals & Pulses', 'Sugar & Jaggery'],
              image: AssetConstants.attaRiceDal),
          _category('cat_oil_ghee_masala', 'Oil, Ghee & Masala', 'sec_grocery',
              Icons.local_fire_department, const Color(0xFFE0592A),
              ['Edible Oils', 'Ghee & Vanaspati', 'Whole Spices', 'Masala & Blends'],
              image: AssetConstants.oilGheeMasala),
          _category('cat_dairy_bread_eggs', 'Dairy, Bread & Eggs', 'sec_grocery',
              Icons.egg_alt, const Color(0xFF2F8FD1),
              ['Milk', 'Bread & Pav', 'Eggs', 'Butter & Cheese'],
              image: AssetConstants.dairyBreadEggs),
          _category('cat_bakery_biscuits', 'Bakery & Biscuits', 'sec_grocery',
              Icons.cookie, const Color(0xFFB07A2E),
              ['Cookies', 'Cream Biscuits', 'Cakes & Rolls', 'Glucose Biscuits'],
              image: AssetConstants.bakeryBiscuits),
          _category('cat_dryfruits_cereals', 'Dry Fruits & Cereals', 'sec_grocery',
              Icons.scatter_plot, const Color(0xFF8A5A2E),
              ['Almonds & Cashews', 'Raisins & Dates', 'Breakfast Cereals', 'Muesli & Oats'],
              image: AssetConstants.dryFruitsCereals),
          _category('cat_kitchenware', 'Kitchenware & Appliances', 'sec_grocery',
              Icons.blender, const Color(0xFF5B6B73),
              ['Cookware', 'Storage & Containers', 'Small Appliances', 'Water Bottles'],
              image: AssetConstants.kitchenwareAppliances),
          _category('cat_chicken_meat_fish', 'Chicken & Meat', 'sec_grocery',
              Icons.set_meal, const Color(0xFFD84315),
              ['Chicken', 'Mutton', 'Fish & Seafood', 'Eggs'],
              image: AssetConstants.chickenMeatFish),
        ],
      ),
      CategorySectionModel(
        id: 'sec_snacks',
        title: 'Snacks & Drinks',
        categories: [
          _category('cat_chips_namkeen', 'Chips & Namkeen', 'sec_snacks',
              Icons.fastfood, const Color(0xFFE0A72A),
              ['Potato Chips', 'Traditional Namkeen', 'Bhujia & Sev', 'Popcorn'],
              image: AssetConstants.chipsNamkeen),
          _category('cat_sweets_choco', 'Sweets & Chocolates', 'sec_snacks',
              Icons.cake, const Color(0xFF8B4A2B),
              ['Indian Sweets', 'Chocolate Bars', 'Gift Packs', 'Candies'],
              image: AssetConstants.sweetsChocolates),
          _category('cat_drinks_juices', 'Drinks & Juices', 'sec_snacks',
              Icons.local_drink, const Color(0xFFE0472A),
              ['Soft Drinks', 'Fruit Juices', 'Energy Drinks', 'Health Drinks'],
              image: AssetConstants.drinksJuices),
          _category('cat_tea_coffee', 'Tea, Coffee & Milk Drinks', 'sec_snacks',
              Icons.emoji_food_beverage, const Color(0xFF6B4226),
              ['Tea', 'Coffee', 'Green Tea', 'Malt Drinks'],
              image: AssetConstants.teaCoffeeMilk),
          _category('cat_instant_food', 'Instant Food', 'sec_snacks',
              Icons.ramen_dining, const Color(0xFFD1562F),
              ['Noodles & Pasta', 'Ready to Eat', 'Frozen Snacks', 'Soup'],
              image: AssetConstants.instantFood),
          _category('cat_sauces_spreads', 'Sauces & Spreads', 'sec_snacks',
              Icons.blender_outlined, const Color(0xFFB6242C),
              ['Ketchup & Sauces', 'Jams & Spreads', 'Honey', 'Peanut Butter'],
              image: AssetConstants.saucesSpreads),
          _category('cat_paan_corner', 'Paan Corner', 'sec_snacks',
              Icons.spa, const Color(0xFF3E7D44),
              ['Mouth Fresheners', 'Supari', 'Digestives', 'Mints'],
              image: AssetConstants.paanCorner),
          _category('cat_ice_creams', 'Ice Creams & More', 'sec_snacks',
              Icons.icecream, const Color(0xFF2FA0C1),
              ['Tubs & Family Packs', 'Cups & Sticks', 'Kulfi', 'Frozen Desserts'],
              image: AssetConstants.iceCreamsMore),
        ],
      ),
      CategorySectionModel(
        id: 'sec_beauty',
        title: 'Beauty & Personal Care',
        categories: [
          _category('cat_bath_body', 'Bath & Body', 'sec_beauty',
              Icons.bathtub, const Color(0xFF2E9E8F),
              ['Soaps & Body Wash', 'Body Lotion', 'Talcum Powder', 'Deodorants'],
              image: AssetConstants.bathBody),
          _category('cat_hair', 'Hair', 'sec_beauty',
              Icons.content_cut, const Color(0xFF7A4A2B),
              ['Shampoo', 'Conditioner', 'Hair Oil', 'Hair Color'],
              image: AssetConstants.hairCare),
          _category('cat_skin_face', 'Skin & Face', 'sec_beauty',
              Icons.face_retouching_natural, const Color(0xFFDB8A7A),
              ['Face Wash', 'Moisturizers', 'Sunscreen', 'Face Masks'],
              image: AssetConstants.skinFace),
          _category('cat_feminine_hygiene', 'Feminine Hygiene', 'sec_beauty',
              Icons.favorite, const Color(0xFFD1477A),
              ['Sanitary Pads', 'Tampons', 'Intimate Wash', 'Menstrual Cups'],
              image: AssetConstants.feminineHygiene),
          _category('cat_baby_care', 'Baby Care', 'sec_beauty',
              Icons.child_care, const Color(0xFF4A90D9),
              ['Diapers', 'Baby Food', 'Baby Skin Care', 'Baby Wipes'],
              image: AssetConstants.babyCare),
          _category('cat_health_pharma', 'Health & Pharma', 'sec_beauty',
              Icons.medical_services, const Color(0xFF2E7D5B),
              ['OTC Medicines', 'Health Supplements', 'First Aid', 'Protein & Nutrition'],
              image: AssetConstants.healthPharma),
          
        ],
      ),
      CategorySectionModel(
        id: 'sec_household',
        title: 'Household Essentials',
        categories: [
          _category('cat_home_lifestyle', 'Home & Lifestyle', 'sec_household',
              Icons.chair, const Color(0xFF8A6A3E),
              ['Bed Linen', 'Home Decor', 'Storage Solutions', 'Plants & Pots'],
              image: AssetConstants.homeLifestyle),
          _category('cat_cleaners_repellents', 'Cleaners & Repellents', 'sec_household',
              Icons.cleaning_services, const Color(0xFF2F7FC1),
              ['Floor Cleaners', 'Detergents', 'Dishwash', 'Mosquito Repellents'],
              image: AssetConstants.cleanersRepellents),
          _category('cat_electronics', 'Electronics', 'sec_household',
              Icons.headphones, const Color(0xFF4A4A4A),
              ['Earphones & Audio', 'Chargers & Cables', 'Batteries', 'Bulbs & Lights'],
              image: AssetConstants.electronicsCategory),
          _category('cat_stationery_games', 'Stationery & Games', 'sec_household',
              Icons.extension, const Color(0xFFD1352F),
              ['Notebooks & Pens', 'Board Games & Cards', 'Art Supplies', 'Toys'],
              image: AssetConstants.stationeryGames),
        ],
      ),
    ];
  }

  static CategoryModel _category(String id, String title, String sectionId,
      IconData icon, Color color, List<String> subCategoryTitles, {String? image}) {
    final subs = <SubCategoryModel>[];
    for (var i = 0; i < subCategoryTitles.length; i++) {
      subs.add(SubCategoryModel(
        id: '${id}_sub$i',
        title: subCategoryTitles[i],
        categoryId: id,
        icon: icon,
      ));
    }
    return CategoryModel(
      id: id,
      title: title,
      sectionId: sectionId,
      icon: icon,
      color: color,
      subCategories: subs,
      image: image,
    );
  }

  static const _brands = [
    'GoFresh',
    'FreshPick',
    'DailyBasket',
    'PureHome',
    'ValueMart',
    "Nature's Best",
  ];

  static const _weights = [
    '250 g',
    '500 g',
    '1 kg',
    '1 L',
    '500 ml',
    'Pack of 6',
    '200 ml',
    '2 pcs',
  ];

  static const _nutrition = [
    'Energy: 120 kcal',
    'Protein: 3 g',
    'Fat: 2 g',
    'Carbohydrates: 18 g',
  ];

  /// Generates a handful of realistic-looking products per subcategory
  /// so every category/subcategory has something to show in the grid.
  static List<ProductModel> _productsFor(CategoryModel category) {
    final products = <ProductModel>[];
    for (var i = 0; i < category.subCategories.length; i++) {
      final sub = category.subCategories[i];
      for (var j = 0; j < 3; j++) {
        final index = i * 3 + j;
        final price = 39.0 + ((index * 17) % 260);
        final mrp = price + 10 + ((index % 5) * 8);
        products.add(ProductModel(
          id: '${sub.id}_p$j',
          name: '${sub.title} Pack ${j + 1}',
          brand: _brands[index % _brands.length],
          weight: _weights[index % _weights.length],
          price: price,
          mrp: mrp,
          rating: 3.4 + ((index % 15) / 10),
          ratingCount: 18 + index * 7,
          icon: category.icon,
          color: category.color,
          categoryId: category.id,
          subCategoryId: sub.id,
          description:
              'Quality-checked ${sub.title.toLowerCase()} sourced for your everyday needs. '
              'Carefully packed and delivered fresh to your doorstep.',
          nutrition: _nutrition,
          deliveryTime: index.isEven ? '8 mins' : '15 mins',
          inStock: index % 11 != 0,
        ));
      }
    }
    return products;
  }

  static List<ProductModel> productsForCategory(String categoryId) {
    final category = sections
        .expand((s) => s.categories)
        .firstWhere((c) => c.id == categoryId);
    return _productsFor(category);
  }
}

