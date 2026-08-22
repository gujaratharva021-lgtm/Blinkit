import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/referral_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/support_provider.dart';
import 'providers/wallet_provider.dart';
import 'features/wishlist/presentation/providers/wishlist_provider.dart';
import 'features/category_nav/providers/category_nav_provider.dart';

// Address Book
import 'features/address_book/data/datasources/address_remote_datasource.dart';
import 'features/address_book/data/repositories/address_repository_impl.dart';
import 'features/address_book/presentation/providers/address_provider.dart';

// GST Details
import 'features/gst_details/data/datasources/gst_mock_datasource.dart';
import 'features/gst_details/data/repositories/gst_repository_impl.dart';
import 'features/gst_details/presentation/providers/gst_provider.dart';

// Gift Cards
import 'features/gift_cards/data/datasources/gift_card_mock_datasource.dart';
import 'features/gift_cards/data/repositories/gift_card_repository_impl.dart';
import 'features/gift_cards/presentation/providers/gift_card_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "GoFresh";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CategoryNavProvider()),
        ChangeNotifierProvider(
          create: (_) => AddressProvider(
            repository: AddressRepositoryImpl(
              dataSource: AddressRemoteDataSource(),
            ),
          ),
        ),
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
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'GoFresh',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});
  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await ApiService.getToken();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
