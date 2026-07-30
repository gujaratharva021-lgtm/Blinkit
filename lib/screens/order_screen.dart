import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'order_status_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<CartProvider>().orders;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Orders',
            style: GoogleFonts.poppins(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No orders yet',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Your orders will appear here',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C831F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Shop Now',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8)
              ],
            ),
            child: Column(
              children: [
                // Order Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFF0C831F).withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('Order #${order.orderId}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          Text(order.date,
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(order.status,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ),
                    ],
                  ),
                ),

                // Order Items
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                              color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              order.items
                                  .map((i) => i.name)
                                  .join(', '),
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                              Icons.inventory_2_outlined,
                              size: 16,
                              color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('${order.items.length} items',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[700])),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey)),
                          Text('₹${order.totalAmount}',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  const Color(0xFF0C831F))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Help Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Support coming soon!',
                                        style:
                                        GoogleFonts.poppins()),
                                    behavior:
                                    SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF0C831F)),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                              child: Text('Help',
                                  style: GoogleFonts.poppins(
                                      color:
                                      const Color(0xFF0C831F),
                                      fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Track Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderStatusScreen(
                                    orderId: order.orderId,
                                    totalAmount: order.totalAmount.toDouble(),
                                    items: order.items,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF2196F3),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                              child: Text('Track',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Reorder Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                for (var item in order.items) {
                                  context
                                      .read<CartProvider>()
                                      .addToCart(
                                      item.name,
                                      item.price,
                                      item.unit,
                                      item.image);
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Items added to cart! 🛒',
                                        style:
                                        GoogleFonts.poppins()),
                                    backgroundColor: Colors.green,
                                    behavior:
                                    SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF0C831F),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                              child: Text('Reorder',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13)),
                            ),
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
      ),
    );
  }
}