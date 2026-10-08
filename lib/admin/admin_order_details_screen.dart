import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final OrderItem order;
  const AdminOrderDetailsScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  late String _currentStatus;
  final List<String> _statuses = ['Order Confirmed', 'Preparing', 'On the way', 'Delivered'];
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFf06626)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _currentStatus,
                    items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: _isUpdating ? null : (val) => setState(() => _currentStatus = val!),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf06626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUpdating 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Status'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            
            // Customer Info
            const Text('Customer Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            _infoRow(Icons.person, 'Email', widget.order.userEmail),
            _infoRow(Icons.phone, 'Phone', widget.order.phoneNumber.isEmpty ? 'Not provided' : widget.order.phoneNumber),
            _infoRow(
              widget.order.customerDeleted ? Icons.delete_forever : Icons.check_circle, 
              'Customer Status', 
              widget.order.customerDeleted ? 'DELETED BY CUSTOMER' : 'ACTIVE ON CUSTOMER APP',
              isError: widget.order.customerDeleted,
            ),
            _infoRow(Icons.location_on, 'Address', widget.order.address),
            _infoRow(Icons.calendar_today, 'Date', DateFormat('MMM dd, yyyy • h:mm a').format(widget.order.dateTime)),

            const SizedBox(height: 25),

            // Order Items
            const Text('Items Ordered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.products.length,
              itemBuilder: (context, index) {
                final item = widget.order.products[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(item.burger.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.fastfood)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.burger.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (item.selectedToppings.isNotEmpty || item.selectedSides.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Extra: ${[...item.selectedToppings, ...item.selectedSides].join(", ")}',
                                  style: const TextStyle(
                                    color: Color(0xFFf06626), 
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w900
                                  ),
                                ),
                              ),
                            Text('x${item.quantity}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('RS ${(item.burger.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
            
            const Divider(height: 40, thickness: 1.5),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFf06626).withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount Paid', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('RS ${widget.order.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFf06626))),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isError ? Colors.red.shade100 : Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isError ? Colors.red : const Color(0xFFf06626)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isError ? Colors.red : const Color(0xFFf06626)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    value, 
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 15, 
                      color: isError ? Colors.red : Colors.black87
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);
    try {
      await Provider.of<OrderProvider>(context, listen: false).updateOrderStatus(widget.order.id, _currentStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated successfully!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}
