import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import 'track_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'My Orders',
                style: TextStyle(
                  color: Color(0xFFf06626),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Toggle Button (Active Orders only as requested)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf06626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Active Orders',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Orders List
            Expanded(
              child: Consumer2<OrderProvider, AuthProvider>(
                builder: (context, orderProvider, authProvider, child) {
                  final userEmail = authProvider.user?.email ?? '';
                  if (userEmail.isEmpty) {
                    return const Center(child: Text('Please log in to see your orders.'));
                  }

                  return StreamBuilder<List<OrderItem>>(
                    stream: orderProvider.getOrdersStream(userEmail),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final orders = snapshot.data ?? [];

                      if (orders.isEmpty) {
                        return const Center(child: Text('No active orders found.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110), // Added bottom padding for floating bar
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Column(
                            children: order.products.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(12),
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        item.burger.imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
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
                                            'Status: ${order.status}',
                                            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'RS ${order.amount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: Color(0xFFf06626),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Actions: Track & Delete
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Delete Button
                                        IconButton(
                                          onPressed: () => _showDeleteConfirmation(context, orderProvider, order.id),
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(height: 10),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TrackOrderScreen(order: order),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFf06626),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Track',
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, OrderProvider provider, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order?'),
        content: const Text('Are you sure you want to remove this order from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await provider.deleteOrder(orderId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order removed successfully.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
