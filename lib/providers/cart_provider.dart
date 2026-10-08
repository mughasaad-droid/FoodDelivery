import 'package:flutter/material.dart';
import '../models/burger.dart';

class CartItem {
  final Burger burger;
  int quantity;
  final bool hasToppings;
  final double extraPrice;
  final List<String> selectedToppings;
  final List<String> selectedSides;

  CartItem({
    required this.burger,
    this.quantity = 1,
    this.hasToppings = false,
    this.extraPrice = 0.0,
    this.selectedToppings = const [],
    this.selectedSides = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'burger': burger.toMap(),
      'quantity': quantity,
      'hasToppings': hasToppings,
      'extraPrice': extraPrice,
      'selectedToppings': selectedToppings,
      'selectedSides': selectedSides,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      burger: Burger.fromMap(map['burger']),
      quantity: map['quantity'] ?? 1,
      hasToppings: map['hasToppings'] ?? false,
      extraPrice: (map['extraPrice'] ?? 0.0).toDouble(),
      selectedToppings: List<String>.from(map['selectedToppings'] ?? []),
      selectedSides: List<String>.from(map['selectedSides'] ?? []),
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += (cartItem.burger.price + cartItem.extraPrice) * cartItem.quantity;
    });
    return total;
  }

  double get baseSubtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.burger.price * cartItem.quantity;
    });
    return total;
  }

  double get toppingsTotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.extraPrice * cartItem.quantity;
    });
    return total;
  }

  double get tax => 50.0;
  double get deliveryFee => 100.0;

  double get total => subtotal + tax + deliveryFee;

  void addItem(
    Burger burger, {
    bool hasToppings = false,
    double extraPrice = 0.0,
    List<String> selectedToppings = const [],
    List<String> selectedSides = const [],
  }) {
    // Generate a unique key based on selected toppings/sides to distinguish combinations
    String toppingsKey = [...selectedToppings, ...selectedSides].join('_');
    String key = toppingsKey.isEmpty ? burger.name : '${burger.name}_$toppingsKey';

    if (_items.containsKey(key)) {
      _items.update(
        key,
        (existingItem) => CartItem(
          burger: existingItem.burger,
          quantity: existingItem.quantity + 1,
          hasToppings: existingItem.hasToppings,
          extraPrice: existingItem.extraPrice,
          selectedToppings: List.from(existingItem.selectedToppings),
          selectedSides: List.from(existingItem.selectedSides),
        ),
      );
    } else {
      _items.putIfAbsent(
        key,
        () => CartItem(
          burger: burger,
          hasToppings: hasToppings,
          extraPrice: extraPrice,
          selectedToppings: List.from(selectedToppings),
          selectedSides: List.from(selectedSides),
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void removeSingleItem(String key) {
    if (!_items.containsKey(key)) return;

    if (_items[key]!.quantity > 1) {
      _items.update(
        key,
        (existingItem) => CartItem(
          burger: existingItem.burger,
          quantity: existingItem.quantity - 1,
          hasToppings: existingItem.hasToppings,
          extraPrice: existingItem.extraPrice,
          selectedToppings: List.from(existingItem.selectedToppings),
          selectedSides: List.from(existingItem.selectedSides),
        ),
      );
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  void incrementQuantity(String key) {
    if (!_items.containsKey(key)) return;

    _items.update(
      key,
      (existingItem) => CartItem(
        burger: existingItem.burger,
        quantity: existingItem.quantity + 1,
        hasToppings: existingItem.hasToppings,
        extraPrice: existingItem.extraPrice,
        selectedToppings: List.from(existingItem.selectedToppings),
        selectedSides: List.from(existingItem.selectedSides),
      ),
    );
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
