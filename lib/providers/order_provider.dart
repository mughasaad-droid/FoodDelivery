import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_provider.dart';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double amount;
  final DateTime dateTime;
  final String status;
  final String address;
  final String userEmail;
  final bool customerDeleted;
  final String phoneNumber;

  OrderItem({
    required this.id,
    required this.products,
    required this.amount,
    required this.dateTime,
    this.status = 'Order Confirmed',
    this.address = '',
    this.userEmail = '',
    this.customerDeleted = false,
    this.phoneNumber = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'products': products.map((x) => x.toMap()).toList(),
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'address': address,
      'userEmail': userEmail,
      'customerDeleted': customerDeleted,
      'phoneNumber': phoneNumber,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      products: List<CartItem>.from(map['products']?.map((x) => CartItem.fromMap(x))),
      amount: (map['amount'] ?? 0.0).toDouble(),
      dateTime: DateTime.parse(map['dateTime']),
      status: map['status'] ?? 'Order Confirmed',
      address: map['address'] ?? '',
      userEmail: map['userEmail'] ?? '',
      customerDeleted: map['customerDeleted'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderItem> _orders = [];

  List<OrderItem> get orders => [..._orders];

  // Listen to orders for a specific user (Filtering out customer deleted ones)
  Stream<List<OrderItem>> getOrdersStream(String userEmail) {
    return _firestore
        .collection('orders')
        .where('userEmail', isEqualTo: userEmail)
        .where('customerDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderItem.fromMap(doc.data())).toList();
      // Sort manually in Dart to avoid needing a Firestore composite index
      orders.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return orders;
    });
  }

  // Listen to a single order's updates
  Stream<OrderItem?> getOrderStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return OrderItem.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total, String address, String userEmail, String phoneNumber) async {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final newOrder = OrderItem(
      id: orderId,
      products: cartProducts,
      amount: total,
      dateTime: DateTime.now(),
      address: address,
      userEmail: userEmail,
      customerDeleted: false,
      phoneNumber: phoneNumber,
    );

    try {
      await _firestore.collection('orders').doc(orderId).set(newOrder.toMap());
      // Local sync if needed, though stream will handle UI
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }

  // Soft delete order for customer
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'customerDeleted': true,
      });
      // Local sync if needed
      _orders.removeWhere((item) => item.id == orderId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting order: $e');
      rethrow;
    }
  }

  // Admin: Listen to ALL orders (Real-time)
  Stream<List<OrderItem>> getAllOrdersStream() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderItem.fromMap(doc.data())).toList();
      // Sort by newest first
      orders.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return orders;
    });
  }

  // Admin: Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Admin: Permanent delete order from Firebase
  Future<void> permanentDeleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      _orders.removeWhere((item) => item.id == orderId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error permanently deleting order: $e');
      rethrow;
    }
  }
}
