import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/burger.dart';
import '../providers/cart_provider.dart';
import '../views/burger_details_screen.dart';

class BurgerCard extends StatelessWidget {
  final Burger burger;
  const BurgerCard({super.key, required this.burger});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BurgerDetailsScreen(burger: burger)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    burger.rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Burger Image
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: burger.imageUrl.startsWith('http')
                      ? Image.network(
                          burger.imageUrl,
                          height: 130,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                        )
                      : Image.asset(
                          burger.imageUrl,
                          height: 130,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                        ),
                ),
              ),
            ),
            // Burger Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    burger.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    burger.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RS ${burger.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFf06626),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(burger);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${burger.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFFf06626),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFf06626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
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
  }
}
