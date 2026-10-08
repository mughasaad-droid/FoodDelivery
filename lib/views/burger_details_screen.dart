import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/burger.dart';
import '../providers/cart_provider.dart';

class BurgerDetailsScreen extends StatefulWidget {
  final Burger burger;
  const BurgerDetailsScreen({super.key, required this.burger});

  @override
  State<BurgerDetailsScreen> createState() => _BurgerDetailsScreenState();
}

class _BurgerDetailsScreenState extends State<BurgerDetailsScreen> {
  final List<String> _selectedToppings = [];
  final List<String> _selectedSides = [];
  final double _sidePrice = 150;

  double get _currentTotal {
    return widget.burger.price + (_selectedSides.length * _sidePrice);
  }

  void _toggleTopping(String name) {
    setState(() {
      if (_selectedToppings.contains(name)) {
        _selectedToppings.remove(name);
      } else {
        _selectedToppings.add(name);
      }
    });
  }

  void _toggleSide(String name) {
    setState(() {
      if (_selectedSides.contains(name)) {
        _selectedSides.remove(name);
      } else {
        _selectedSides.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: (widget.burger.imageUrl.startsWith('http')
                          ? NetworkImage(widget.burger.imageUrl)
                          : AssetImage(widget.burger.imageUrl)) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf06626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.burger.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFf06626)),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.burger.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 5),
                      Text(widget.burger.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 25),
                      const Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
                      const SizedBox(width: 5),
                      const Text('20 min', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  const Text('Toppings (free)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),
                  
                  // Free Toppings Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _toppingItem('Tomato', 'assets/tomatos.png', _selectedToppings.contains('Tomato'), () => _toggleTopping('Tomato')),
                        _toppingItem('Pickles', 'assets/pick.png', _selectedToppings.contains('Pickles'), () => _toggleTopping('Pickles')),
                        _toppingItem('Onions', 'assets/on.png', _selectedToppings.contains('Onions'), () => _toggleTopping('Onions')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text('Side Options (RS ${_sidePrice} on all )', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),

                  // Side Options Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _toppingItem('Fries', 'assets/fri.png', _selectedSides.contains('Fries'), () => _toggleSide('Fries')),
                        _toppingItem('Onion Rings', 'assets/rin.png', _selectedSides.contains('Onion Rings'), () => _toggleSide('Onion Rings')),
                        _toppingItem('Salate', 'assets/sal.png', _selectedSides.contains('Salate'), () => _toggleSide('Salate')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('Cold Drinks (RS $_sidePrice on all )', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),

                  // Side Options Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _toppingItem('Pepsi', 'assets/pep.png', _selectedSides.contains('Pepsi'), () => _toggleSide('Pepsi')),
                        _toppingItem('Coke', 'assets/coca.png', _selectedSides.contains('Coke'), () => _toggleSide('Coke')),
                        _toppingItem('Sprite', 'assets/ite.png', _selectedSides.contains('Sprite'), () => _toggleSide('Sprite')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacer for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total :RS ${_currentTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(
                    widget.burger,
                    hasToppings: _selectedToppings.isNotEmpty || _selectedSides.isNotEmpty,
                    extraPrice: _selectedSides.length * _sidePrice,
                    selectedToppings: _selectedToppings,
                    selectedSides: _selectedSides,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.burger.name} added to cart!'),
                      backgroundColor: const Color(0xFFf06626),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf06626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toppingItem(String name, String imageUrl, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFFf06626) : Colors.grey.shade100, width: 2),
        ),
        child: Column(
          children: [
            Image.asset(imageUrl, width: 60, height: 60, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Icon(isSelected ? Icons.check_circle : Icons.add_circle, color: const Color(0xFFf06626), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
