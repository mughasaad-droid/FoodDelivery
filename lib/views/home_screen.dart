import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/burger_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_selector.dart';
import '../models/burger.dart';
import 'location_picker_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart'; // Import OrdersScreen
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/burger_provider.dart';
import 'auth_intro_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeContent(),
    const CartScreen(),
    const OrdersScreen(), // Link OrdersScreen
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                  color: const Color(0xFFf06626),
                ),
                title: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Color(0xFFf06626),
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthIntroScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('SaadFood v1.0', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _screens[navProvider.currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 90,
                    padding: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: (themeProvider.isDarkMode ? Colors.black : Colors.white).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: (themeProvider.isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
                        width: 1.0,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                      ),
                      child: BottomNavigationBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: const Color(0xFFf06626),
                        unselectedItemColor: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        showUnselectedLabels: true,
                        iconSize: 28,
                        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: const TextStyle(fontSize: 10),
                        currentIndex: navProvider.currentIndex,
                        onTap: (index) {
                          navProvider.setIndex(index);
                        },
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
                          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
                          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Orders'),
                          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for Home Content to maintain current structure
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Notification Preview Box State
  bool _showNotificationBox = false;
  String _lastOrderedItem = '';
  Timer? _notificationTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _showNotification() {
    if (_showNotificationBox) {
      setState(() {
        _showNotificationBox = false;
      });
      _notificationTimer?.cancel();
      return;
    }

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (orderProvider.orders.isNotEmpty) {
      final latestOrder = orderProvider.orders.first;
      if (latestOrder.products.isNotEmpty) {
        setState(() {
          _lastOrderedItem = latestOrder.products.first.burger.name;
          _showNotificationBox = true;
        });

        // Auto-dismiss after 3 seconds
        _notificationTimer?.cancel();
        _notificationTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showNotificationBox = false;
            });
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders yet!')),
      );
    }
  }

  List<Burger> _getFilteredBurgers(List<Burger> allBurgers) {
    // Apply search filter (Global)
    if (_searchQuery.isNotEmpty) {
      return allBurgers
          .where((burger) =>
              burger.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              burger.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter if no search query
    if (_selectedCategory == 'All') {
      return allBurgers;
    }
    return allBurgers.where((burger) => burger.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final burgerProvider = Provider.of<BurgerProvider>(context);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _showNotification,
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, size: 28),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
                          );
                          if (result != null && result is String) {
                            if (mounted) {
                              Provider.of<LocationProvider>(context, listen: false).setAddress(result);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 20),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Consumer<LocationProvider>(
                                builder: (context, location, _) => Text(
                                  location.currentAddress,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110), // Added bottom padding for floating bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search menu ',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFFf06626)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.orange.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFFf06626)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const PromoBanner(),
                      const SizedBox(height: 20),

                      CategorySelector(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      StreamBuilder<List<Burger>>(
                        stream: burgerProvider.burgersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFFf06626)));
                          }

                          final allBurgers = snapshot.data ?? [];
                          
                          // First time upload dummy data if Firestore is empty
                          if (allBurgers.isEmpty && _searchQuery.isEmpty) {
                            burgerProvider.uploadDummyData();
                            return const Center(child: Text('Loading Menu...', style: TextStyle(color: Colors.grey)));
                          }

                          final filteredBurgers = _getFilteredBurgers(allBurgers);

                          if (filteredBurgers.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    const Icon(Icons.search_off, size: 80, color: Colors.grey),
                                    const SizedBox(height: 10),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No burgers found for "$_searchQuery"'
                                          : 'No burgers found in this category',
                                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            itemCount: filteredBurgers.length,
                            itemBuilder: (context, index) {
                              return BurgerCard(burger: filteredBurgers[index]);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Notification Preview Box
          if (_showNotificationBox)
            Positioned(
              top: 50,
              left: 20,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf06626),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Last Order: $_lastOrderedItem',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
