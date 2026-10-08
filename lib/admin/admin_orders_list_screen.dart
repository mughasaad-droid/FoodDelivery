import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersListScreen extends StatelessWidget {
  const AdminOrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        title: const Text('Manage Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFf06626)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<OrderItem>>(
        stream: orderProvider.getAllOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFf06626)));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final date = DateFormat('MMM dd, yyyy • h:mm a').format(order.dateTime);
              
              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order #${order.id.length > 5 ? order.id.substring(order.id.length - 5) : order.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          _customerStatusBadge(order.customerDeleted),
                        ],
                      ),
                      _statusBadge(order.status),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(order.userEmail, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      if (order.phoneNumber.isNotEmpty)
                        Text('Tel: ${order.phoneNumber}', style: const TextStyle(color: Color(0xFFf06626), fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${order.products.length} Items',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'RS ${order.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626), fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => AdminOrderDetailsScreen(order: order))
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _showDeleteDialog(context, orderProvider, order.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, OrderProvider provider, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order?'),
        content: const Text('Are you sure you want to permanently delete this order from Firebase?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.permanentDeleteOrder(orderId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order deleted from Firebase.'), backgroundColor: Colors.redAccent),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _customerStatusBadge(bool isDeleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDeleted ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDeleted ? Colors.red : Colors.green,
          width: 1,
        ),
      ),
      child: Text(
        isDeleted ? 'DELETED' : 'ACTIVE',
        style: TextStyle(
          color: isDeleted ? Colors.red : Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Order Confirmed':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'Preparing':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'On the way':
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      case 'Delivered':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
