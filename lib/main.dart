import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/push_notification_service.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/referral_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/support_provider.dart';
import 'features/category_nav/providers/category_nav_provider.dart';
import 'screens/splash_screen.dart';

// New modules
import 'features/address_book/data/datasources/address_mock_datasource.dart';
import 'features/address_book/data/repositories/address_repository_impl.dart';
import 'features/address_book/presentation/providers/address_provider.dart';
import 'features/wishlist/presentation/providers/wishlist_provider.dart';
import 'features/gst_details/data/datasources/gst_mock_datasource.dart';
import 'features/gst_details/data/repositories/gst_repository_impl.dart';
import 'features/gst_details/presentation/providers/gst_provider.dart';
import 'features/gift_cards/data/datasources/gift_card_mock_datasource.dart';
import 'features/gift_cards/data/repositories/gift_card_repository_impl.dart';
import 'features/gift_cards/presentation/providers/gift_card_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  try {
    await PushNotificationService.initialize();
  } catch (e) {
    print('Push notification init failed: $e');
  }
  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => CategoryNavProvider()),

        // New modules
        ChangeNotifierProvider(
          create: (_) => AddressProvider(
            repository: AddressRepositoryImpl(
              dataSource: AddressMockDataSource(),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(
          create: (_) => GstProvider(
            repository: GstRepositoryImpl(
              dataSource: GstMockDataSource(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GiftCardProvider(
            repository: GiftCardRepositoryImpl(
              dataSource: GiftCardMockDataSource(),
            ),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'GoFresh',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
