import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedPaymentMethod;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFf06626).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFf06626), size: 18),
            ),
          ),
        ),
        title: const Text(
          'Order Summary',
          style: TextStyle(color: Color(0xFFf06626), fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items Summary
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          item.burger.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.burger.name + (item.hasToppings ? " + Additional" : ""),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              item.burger.description,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'RS ${item.burger.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFf06626),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Simple Quantity display
                      Text('x ${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 30),
            ),

            // Price Breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _summaryRow('Subtotal', 'RS ${cart.baseSubtotal.toStringAsFixed(0)}'),
                  if (cart.toppingsTotal > 0) ...[
                    const SizedBox(height: 10),
                    _summaryRow('Additional Toppings', 'RS ${cart.toppingsTotal.toStringAsFixed(0)}'),
                  ],
                  const SizedBox(height: 10),
                  _summaryRow('Tax', 'RS ${cart.tax.toStringAsFixed(0)}'),
                  const SizedBox(height: 10),
                  _summaryRow('Delivery fee', 'RS ${cart.deliveryFee.toStringAsFixed(0)}'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'RS ${cart.total.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Phone Number Input
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Contact Number',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFFf06626)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFf06626)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Payment Methods
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Payment methods',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 15),

            _paymentOption(
              title: 'Credit card',
              subtitle: '10101 **** **** 3546',
              iconUrl: 'https://img.icons8.com/color/48/000000/mastercard.png',
              value: 'credit',
            ),
            _paymentOption(
              title: 'Debit card',
              subtitle: '10101 **** **** 3546',
              iconUrl: 'https://img.icons8.com/color/48/000000/visa.png',
              value: 'debit',
            ),
            _paymentOption(
              title: 'Cash on delivery',
              value: 'cod',
            ),

            const SizedBox(height: 30),

            // Place Order Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedPaymentMethod == null
                      ? null
                      : () async {
                          if (_phoneController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your phone number to place the order.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final userEmail = Provider.of<AuthProvider>(context, listen: false).user?.email ?? 'anonymous';
                          final address = Provider.of<LocationProvider>(context, listen: false).currentAddress;

                          // 1. Save Order to Firestore
                          try {
                            await orderProvider.addOrder(
                              cartItems, 
                              cart.total, 
                              address, 
                              userEmail, 
                              _phoneController.text.trim(),
                            );
                            
                            // 2. Clear Cart
                            cart.clear();
                            
                            // 3. Set Tab to "Orders" (Index 2)
                            navProvider.setIndex(2);
                            
                            // 4. Close Checkout Screen
                            if (mounted) {
                              Navigator.pop(context);
                              
                              // 5. Show Success Snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order Placed Successfully!'),
                                  backgroundColor: Color(0xFFf06626),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to place order: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf06626),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _paymentOption({required String title, String? subtitle, String? iconUrl, required String value}) {
    bool isSelected = _selectedPaymentMethod == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? const Color(0xFFf06626) : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (iconUrl != null) ...[
                Image.network(
                  iconUrl,
                  width: 40,
                  height: 25,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.credit_card, size: 25, color: Colors.grey),
                ),
                const SizedBox(width: 15),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: value == 'cod' && !isSelected ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFf06626) : Colors.black,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFf06626),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
