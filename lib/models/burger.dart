class Burger {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String imageUrl;
  final String category;

  Burger({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  factory Burger.fromMap(Map<String, dynamic> map) {
    return Burger(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }
}

// Dummy data for burgers with categories
final List<Burger> dummyBurgers = [
  Burger(
    id: '1',
    name: 'Classic Beef Burger',
    description: 'Fresh beef patty with lettuce and tomato.',
    price: 500.0,
    rating: 3.8,
    imageUrl: 'assets/bur.png',
    category: 'Classic',
  ),
  Burger(
    id: '2',
    name: 'Cheeseburger',
    description: 'Beef patty with melted cheddar cheese.',
    price: 350.0,
    rating: 4.8,
    imageUrl: 'assets/cheese.png',
    category: 'Classic',
  ),
  Burger(
    id: '3',
    name: 'Spicy Zinger',
    description: 'Crispy chicken with spicy jalapenos and mayo.',
    price: 300.0,
    rating: 4.5,
    imageUrl: 'assets/spic.png',
    category: 'Spicy',
  ),
  Burger(
    id: '4',
    name: 'BBQ Beef Burger',
    description: 'Beef patty with smoky BBQ sauce and onions.',
    price: 400.0,
    rating: 4.2,
    imageUrl: 'assets/gri.png',
    category: 'Sliders',
  ),
  Burger(
    id: '5',
    name: 'Mushroom Swiss',
    description: 'Sautéed mushrooms with swiss cheese.',
    price: 450.0,
    rating: 4.7,
    imageUrl: 'assets/mush.png',
    category: 'Classic',
  ),
  Burger(
    id: '6',
    name: 'Double Decker',
    description: 'Two beef patties for double the taste.',
    price: 600.0,
    rating: 4.9,
    imageUrl: 'assets/dou.png',
    category: 'Combo',
  ),
  Burger(
    id: '7',
    name: 'Fillet Burger',
    description: 'Grilled Fillet with lettuce and tomato.',
    price: 320.0,
    rating: 4.3,
    imageUrl: 'assets/fill.png',
    category: 'Combo',
  ),
  Burger(
    id: '8',
    name: 'Chicken Shawarma',
    description: 'Grilled cicken with smoky BBQ sauce and onions.',
    price: 250.0,
    rating: 4.9,
    imageUrl: 'assets/shaw.png',
    category: 'Sliders',
  ),
];
