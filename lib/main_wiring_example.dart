// This file shows how to wire the four new modules into an existing
// Flutter app. Merge the relevant pieces into your current main.dart —
// don't just drop this in wholesale if you already have a MultiProvider
// / GoRouter setup; add these providers and routes to your existing ones.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/new_modules_theme.dart';
import 'routes/new_modules_routes.dart';

// Address Book
import 'features/address_book/data/datasources/address_mock_datasource.dart';
import 'features/address_book/data/repositories/address_repository_impl.dart';
import 'features/address_book/presentation/providers/address_provider.dart';

// Wishlist
import 'features/wishlist/presentation/providers/wishlist_provider.dart';

// GST Details
import 'features/gst_details/data/datasources/gst_mock_datasource.dart';
import 'features/gst_details/data/repositories/gst_repository_impl.dart';
import 'features/gst_details/presentation/providers/gst_provider.dart';

// Gift Cards
import 'features/gift_cards/data/datasources/gift_card_mock_datasource.dart';
import 'features/gift_cards/data/repositories/gift_card_repository_impl.dart';
import 'features/gift_cards/presentation/providers/gift_card_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ...keep your existing providers here...

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
      child: MaterialApp.router(
        title: 'Blinkit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

// Merge `newModuleRoutes` into your existing GoRouter's routes list —
// this standalone router is only here so the example is runnable as-is.
final GoRouter _router = GoRouter(
  initialLocation: AppRoutePaths.addressBook,
  routes: [
    // ...keep your existing routes here...
    ...newModuleRoutes,
  ],
);

