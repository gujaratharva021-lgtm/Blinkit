import 'package:go_router/go_router.dart';
import '../features/address_book/presentation/screens/address_list_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/gst_details/presentation/screens/gst_list_screen.dart';
import '../features/gift_cards/presentation/screens/gift_cards_screen.dart';
import '../features/gift_cards/presentation/screens/redeem_gift_card_screen.dart';

/// Route path constants ??" reference these instead of hardcoded strings
/// wherever you navigate to these screens.
class AppRoutePaths {
  AppRoutePaths._();

  static const addressBook = '/account/addresses';
  static const wishlist = '/wishlist';
  static const gstDetails = '/account/gst-details';
  static const giftCards = '/account/gift-cards';
  static const redeemGiftCard = '/account/gift-cards/redeem';
}

/// Merge this list into your existing GoRouter's `routes: [...]`.
final List<RouteBase> newModuleRoutes = [
  GoRoute(
    path: AppRoutePaths.addressBook,
    name: 'addressBook',
    builder: (context, state) => const AddressListScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.wishlist,
    name: 'wishlist',
    builder: (context, state) => const WishlistScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.gstDetails,
    name: 'gstDetails',
    builder: (context, state) => const GstListScreen(),
  ),
  GoRoute(
    path: AppRoutePaths.giftCards,
    name: 'giftCards',
    builder: (context, state) => const GiftCardsScreen(),
    routes: [
      GoRoute(
        path: 'redeem',
        name: 'redeemGiftCard',
        builder: (context, state) => const RedeemGiftCardScreen(),
      ),
    ],
  ),
];

