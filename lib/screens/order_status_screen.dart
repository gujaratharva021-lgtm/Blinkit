import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final List<CartItem> items;

  const OrderStatusScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.items,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _minutes = 10;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(seconds: 1), _countdown);
  }

  void _countdown() {
    if (!mounted) return;
    if (_minutes > 0) {
      setState(() => _minutes--);
      Future.delayed(const Duration(minutes: 1), _countdown);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Status',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.redAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1), blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arriving in',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.grey)),
                          Text('$_minutes mins',
                              style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2196F3))),
                        ],
                      ),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('⚡ Early',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Your order is on the way!',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Woah, that was fast 🚀',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF2196F3))),
                  const SizedBox(height: 16),
                  _buildProgressSteps(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Actual Items Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C831F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined,
                            color: Color(0xFF0C831F)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.items.length} Item(s)',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Order #${widget.orderId}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // ✅ Actual item list
                  ...widget.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.image.startsWith('assets/')
                              ? Image.asset(item.image,
                              width: 44, height: 44, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 44, height: 44,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey, size: 20)))
                              : Image.network(item.image,
                              width: 44, height: 44, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 44, height: 44,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey, size: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              Text(item.unit,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('x${item.quantity}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey)),
                            Text('₹${item.price * item.quantity}',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0C831F))),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Delivery Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Text(
                'I have arrived at the gate and will be on your doorstep soon',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.brown[700]),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Delivery Partner Card — dynamic name future ke liye ready
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                    const Color(0xFF0C831F).withOpacity(0.2),
                    child: const Icon(Icons.delivery_dining,
                        color: Color(0xFF0C831F), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivery Partner',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey)),
                        Text('Vivek Kumar',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, color: Color(0xFF0C831F)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pay Online Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.pink.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'You can pay online now while we deliver your order',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To Pay:',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey)),
                          Text(
                              '₹${widget.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text('Pay Online →',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Need Help
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need help with this order?',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Find your issue or reach out via chat',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = ['Order Placed', 'Preparing', 'On the Way', 'Delivered'];
    const currentStep = 2;

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF2196F3)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[index],
                        style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: isCompleted
                                ? const Color(0xFF2196F3)
                                : Colors.grey),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentStep
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}