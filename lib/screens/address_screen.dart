import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'order_screen.dart';

class AddressScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int totalAmount;

  const AddressScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int _selectedAddress = 0;
  late Razorpay _razorpay;
  bool _isLoading = false;

  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadAddresses();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ✅ Load addresses from SharedPreferences
  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('saved_addresses');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _addresses = decoded.map((e) {
          final map = Map<String, dynamic>.from(e);
          map['icon'] = _iconFromType(map['type']);
          return map;
        }).toList();
      });
    } else {
      // Default addresses pehli baar
      setState(() {
        _addresses = [
          {
            'type': 'Home',
            'icon': Icons.home_outlined,
            'name': 'Atharv',
            'address': 'Flat 402, Shanti Nagar, Andheri West',
            'city': 'Mumbai, Maharashtra 400053',
            'phone': '+91 98765 43210',
          },
          {
            'type': 'Office',
            'icon': Icons.work_outline,
            'name': 'Atharv',
            'address': 'Unit 5, Tech Park, Bandra Kurla Complex',
            'city': 'Mumbai, Maharashtra 400051',
            'phone': '+91 98765 43210',
          },
        ];
      });
      _saveAddresses();
    }
  }

  // ✅ Save addresses to SharedPreferences
  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> toSave = _addresses.map((e) {
      final map = Map<String, dynamic>.from(e);
      map.remove('icon'); // IconData serialize nahi hoti
      return map;
    }).toList();
    await prefs.setString('saved_addresses', jsonEncode(toSave));
  }

  IconData _iconFromType(String type) {
    switch (type) {
      case 'Home': return Icons.home_outlined;
      case 'Office': return Icons.work_outline;
      default: return Icons.location_on_outlined;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final selected = _addresses[_selectedAddress];
    final fullAddress = '${selected['address']}, ${selected['city']}';
    try {
      await ApiService.directPlaceOrder(fullAddress, widget.items);
      if (mounted) {
        context.read<CartProvider>().placeOrder();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment Successful! Order Placed 🎉',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error placing order', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment Failed: ${response.message}',
          style: GoogleFonts.poppins()),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('External Wallet: ${response.walletName}',
          style: GoogleFonts.poppins()),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _startPayment() async {
    setState(() => _isLoading = true);
    try {
      final orderData = await ApiService.createPaymentOrder(widget.totalAmount);
      var options = {
        'key': orderData['key_id'],
        'amount': widget.totalAmount * 100,
        'name': 'Mepto',
        'order_id': orderData['order_id'],
        'description': 'Grocery Order',
        'prefill': {
          'contact': '9999999999',
          'email': 'test@mepto.com',
        },
        'method': {'upi': true, 'card': true, 'netbanking': true, 'wallet': true},
        'theme': {'color': '#D4A574'},
      };
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error initiating payment', style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
    setState(() => _isLoading = false);
  }

  // ✅ Add & Edit — ek hi sheet, index pass karo edit ke liye
  void _showAddressSheet({int? editIndex}) {
    final existing = editIndex != null ? _addresses[editIndex] : null;

    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final addressController = TextEditingController(text: existing?['address'] ?? '');
    final cityController = TextEditingController(text: existing?['city'] ?? '');
    final phoneController = TextEditingController(text: existing?['phone'] ?? '');
    String selectedType = existing?['type'] ?? 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(editIndex != null ? 'Edit Address' : 'Add New Address',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Type selector
                  Row(
                    children: ['Home', 'Office', 'Other'].map((type) {
                      final isSelected = selectedType == type;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0C831F)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(type,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(nameController, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildTextField(phoneController, 'Phone Number', Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(addressController, 'Flat, Street, Area',
                      Icons.location_on_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  _buildTextField(cityController, 'City, State, Pincode',
                      Icons.location_city_outlined),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            addressController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please fill all fields',
                                style: GoogleFonts.poppins()),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                          return;
                        }

                        final newAddress = {
                          'type': selectedType,
                          'icon': _iconFromType(selectedType),
                          'name': nameController.text,
                          'address': addressController.text,
                          'city': cityController.text,
                          'phone': phoneController.text,
                        };

                        setState(() {
                          if (editIndex != null) {
                            // ✅ Edit mode
                            _addresses[editIndex] = newAddress;
                          } else {
                            // ✅ Add mode
                            _addresses.add(newAddress);
                          }
                        });

                        _saveAddresses(); // persist
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              editIndex != null
                                  ? 'Address updated! ✅'
                                  : 'Address saved! ✅',
                              style: GoogleFonts.poppins()),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C831F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                          editIndex != null ? 'Update Address' : 'Save Address',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF0C831F), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0C831F), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C831F),
        title: Text('Select Delivery Address',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressSheet(),
        backgroundColor: const Color(0xFF0C831F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Address',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _addresses.isEmpty
          ? Center(
        child: Text('No addresses saved',
            style: GoogleFonts.poppins(color: Colors.grey)),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          final isSelected = _selectedAddress == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedAddress = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0C831F)
                        : Colors.transparent,
                    width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8)
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C831F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(address['icon'],
                        color: const Color(0xFF0C831F), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(address['type'],
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF0C831F),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text('Selected',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 10)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(address['name'],
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(address['address'],
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                        Text(address['city'],
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                        Text(address['phone'],
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // ✅ Edit button — ab kaam karega
                            GestureDetector(
                              onTap: () => _showAddressSheet(editIndex: index),
                              child: Text('Edit',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF0C831F),
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _addresses.removeAt(index);
                                  if (_selectedAddress >= _addresses.length) {
                                    _selectedAddress = 0;
                                  }
                                });
                                _saveAddresses(); // persist delete bhi
                              },
                              child: Text('Delete',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading || _addresses.isEmpty ? null : _startPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C831F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2)
              : Text('Pay ₹${widget.totalAmount}',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}