/// Central registry of local asset image paths used across the app.
/// Category images are placeholder art generated as stand-ins —
/// swap the files in assets/categories/ with real photography whenever
/// it's available; the paths/filenames below can stay the same.
class AssetConstants {
  AssetConstants._();

  static const String _base = 'assets/categories';

  static const String fruits = '$_base/fruits.png';
  static const String beverages = '$_base/beverages.png';
  static const String bakery = '$_base/bakery.png';
  static const String biscuits = '$_base/biscuits.png';
  static const String namkeen = '$_base/namkeen.png';
  static const String wafers = '$_base/wafers.png';
  static const String ketchup = '$_base/ketchup.png';
  static const String shampoo = '$_base/shampoo.png';
  static const String soap = '$_base/soap.png';
  static const String personalCare = '$_base/personal_care.png';
  static const String pickle = '$_base/pickle.png';
  static const String pujaItems = '$_base/puja_items.png';
  static const String toys = '$_base/toys.png';
  static const String clothes = '$_base/clothes.png';
  static const String iceCreams = '$_base/ice_creams.png';
  static const String chocolate = '$_base/chocolate.png';

  // Grocery & Kitchen home-category images (category_nav module)
  static const String vegetablesFruits = '$_base/vegetables_fruits.png';
  static const String attaRiceDal = '$_base/atta_rice_dal.png';
  static const String oilGheeMasala = '$_base/oil_ghee_masala.png';
  static const String dairyBreadEggs = '$_base/dairy_bread_eggs.png';
  static const String bakeryBiscuits = '$_base/bakery_biscuits.png';
  static const String dryFruitsCereals = '$_base/dry_fruits_cereals.png';
  static const String chickenMeatFish = '$_base/chicken_meat_fish.png';
  static const String kitchenwareAppliances = '$_base/kitchenware_appliances.png';
}
