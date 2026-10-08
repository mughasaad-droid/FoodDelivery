import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'admin_orders_list_screen.dart';
import 'admin_burger_list_screen.dart';
import 'admin_comments_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<OrderItem>>(
        stream: orderProvider.getAllOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFf06626)));
          }
          
          final orders = snapshot.data ?? [];
          final pendingOrders = orders.where((o) => o.status == 'Order Confirmed').length;
          final preparingOrders = orders.where((o) => o.status == 'Preparing').length;
          final totalSales = orders.fold(0.0, (sum, item) => sum + item.amount);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Overview',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard('Total Orders', '${orders.length}', Icons.shopping_bag, Colors.blue),
                    _buildStatCard('Pending', '$pendingOrders', Icons.timer, Colors.orange),
                    _buildStatCard('Preparing', '$preparingOrders', Icons.restaurant, Colors.purple),
                    _buildStatCard('Revenue', 'RS ${totalSales.toStringAsFixed(0)}', Icons.payments, Colors.green),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Text(
                  'Management',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                
                // Navigation Buttons
                _buildMenuTile(
                  context, 
                  'Manage Orders', 
                  'View and update order status', 
                  Icons.assignment, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersListScreen()))
                ),
                _buildMenuTile(
                  context, 
                  'Burger Menu', 
                  'Add, edit or delete burgers', 
                  Icons.fastfood, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBurgerListScreen()))
                ),
                _buildMenuTile(
                  context, 
                  'Customer Feedback', 
                  'Read comments and suggestions', 
                  Icons.comment, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCommentsScreen()))
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback? onTap) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFf06626).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFFf06626)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
