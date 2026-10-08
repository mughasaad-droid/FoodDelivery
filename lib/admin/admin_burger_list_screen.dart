import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/burger_provider.dart';
import '../models/burger.dart';
import 'add_burger_screen.dart';

class AdminBurgerListScreen extends StatelessWidget {
  const AdminBurgerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final burgerProvider = Provider.of<BurgerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        title: const Text('Burger Menu', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFf06626)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBurgerScreen())),
            icon: const Icon(Icons.add_circle, color: Color(0xFFf06626), size: 30),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<List<Burger>>(
        stream: burgerProvider.burgersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFf06626)));
          }

          final burgers = snapshot.data ?? [];
          if (burgers.isEmpty) {
            return const Center(child: Text('No burgers found. Click + to add.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: burgers.length,
            itemBuilder: (context, index) {
              final burger = burgers[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: burger.imageUrl.startsWith('http')
                        ? Image.network(
                            burger.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 60),
                          )
                        : Image.asset(
                            burger.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 60),
                          ),
                  ),
                  title: Text(burger.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${burger.category} • RS ${burger.price.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _showDeleteDialog(context, burgerProvider, burger),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BurgerProvider provider, Burger burger) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Burger?'),
        content: Text('Are you sure you want to delete ${burger.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteBurger(burger.id);
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
