import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

import 'checkout_screen.dart'; // Import CheckoutScreen

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartEntries = cart.items.entries.toList();
    final cartItems = cart.items.values.toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Cart (${cart.itemCount})',
                    style: const TextStyle(
                      color: Color(0xFFf06626),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cartItems.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => cart.clear(),
                      icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: cartEntries.isEmpty
                  ? const Center(child: Text('Your cart is empty!'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: cartEntries.length,
                      itemBuilder: (context, index) {
                        final entry = cartEntries[index];
                        final key = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Food Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _burgerImage(item.burger),
                              ),
                              const SizedBox(width: 15),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.burger.name + (item.hasToppings ? " + Extra" : ""),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (item.selectedToppings.isNotEmpty || item.selectedSides.isNotEmpty)
                                      Text(
                                        [...item.selectedToppings, ...item.selectedSides].join(", "),
                                        style: const TextStyle(color: Color(0xFFf06626), fontSize: 11, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      item.burger.description,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'RS ${(item.burger.price + item.extraPrice).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Color(0xFFf06626),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Row(
                                children: [
                                  _quantityButton(
                                    icon: Icons.remove,
                                    onPressed: () => cart.removeSingleItem(key),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _quantityButton(
                                    icon: Icons.add,
                                    onPressed: () => cart.incrementQuantity(key),
                                    isAdd: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Summary Section
            if (cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 110), // Added 110 bottom padding
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                  children: [
                    _summaryRow('Subtotal', 'RS ${cart.baseSubtotal.toStringAsFixed(0)}'),
                    if (cart.toppingsTotal > 0) ...[
                      const SizedBox(height: 10),
                      _summaryRow('Additional Toppings', 'RS ${cart.toppingsTotal.toStringAsFixed(0)}'),
                    ],
                    const SizedBox(height: 8), // Slightly reduced spacing
                    _summaryRow('Tax', 'RS ${cart.tax.toStringAsFixed(0)}'),
                    const SizedBox(height: 8), // Slightly reduced spacing
                    _summaryRow('Delivery fee', 'RS ${cart.deliveryFee.toStringAsFixed(0)}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15), // Slightly reduced vertical padding
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Reduced font size
                        ),
                        Text(
                          'RS ${cart.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Reduced font size
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7, // Reduced width to 70% of screen
                      height: 48, // Reduced height from 55 to 48
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                          );
                        }, // Checkout action
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFf06626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Check out',
                          style: TextStyle(color: Colors.white, fontSize: 16), // Reduced font size
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onPressed, bool isAdd = false}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isAdd ? const Color(0xFFf06626) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          icon,
          color: isAdd ? Colors.white : const Color(0xFFf06626),
          size: 18,
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

  Widget _burgerImage(dynamic burger) {
    if (burger.imageUrl.startsWith('http')) {
      return Image.network(
        burger.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40),
      );
    }
    return Image.asset(
      burger.imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 40),
    );
  }
}
