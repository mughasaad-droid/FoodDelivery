import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class TrackOrderScreen extends StatelessWidget {
  final OrderItem order;
  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFf06626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Track Order',
            style: TextStyle(color: Color(0xFFf06626), fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Logo or Branding Header instead of Map
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFf06626).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining,
                size: 80,
                color: Color(0xFFf06626),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Order #${order.id.length > 5 ? order.id.substring(order.id.length - 5) : order.id}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Tracking Status List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: StreamBuilder<OrderItem?>(
                stream: Provider.of<OrderProvider>(context, listen: false).getOrderStream(order.id),
                initialData: order,
                builder: (context, snapshot) {
                  final currentOrder = snapshot.data ?? order;
                  final status = currentOrder.status;

                  // Logic for checkboxes based on status (Automatic updates)
                  bool isConfirmed = true; 
                  bool isPreparing = status == 'Preparing' || status == 'On the way' || status == 'Delivered';
                  bool isOnTheWay = status == 'On the way' || status == 'Delivered';
                  bool isDelivered = status == 'Delivered';

                  // Time calculation logic
                  final confirmedTime = DateFormat('h:mm a').format(currentOrder.dateTime);
                  final preparingTime = DateFormat('h:mm a').format(currentOrder.dateTime.add(const Duration(minutes: 10)));
                  final onTheWayTime = DateFormat('h:mm a').format(currentOrder.dateTime.add(const Duration(minutes: 20)));

                  return Column(
                    children: [
                      _buildTrackStep('Order Confirmed', confirmedTime, isConfirmed, true),
                      _buildTrackStep('Preparing', preparingTime, isPreparing, true),
                      _buildTrackStep('On the way', onTheWayTime, isOnTheWay, true),
                      _buildTrackStep('Delivered', isDelivered ? 'Delivered' : '', isDelivered, false),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep(String title, String time, bool isDone, bool showLine) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFf06626) : Colors.white,
                  border: Border.all(
                    color: const Color(0xFFf06626),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFf06626).withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
