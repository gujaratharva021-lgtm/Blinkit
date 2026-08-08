import 'package:flutter/material.dart';
import '../screens/orders/order_list_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/support/support_home_screen.dart';
import '../screens/support/report_issue_screen.dart';

class AppRoutes {
  static const orders = '/orders';
  static const wallet = '/wallet';
  static const support = '/support';
  static const reportIssue = '/support/report';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case orders:
        return MaterialPageRoute(builder: (_) => const OrderListScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case support:
        return MaterialPageRoute(builder: (_) => const SupportHomeScreen());
      case reportIssue:
        return MaterialPageRoute(builder: (_) => const ReportIssueScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}
