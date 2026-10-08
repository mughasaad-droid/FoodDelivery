import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/burger_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/location_provider.dart';
import 'providers/comment_provider.dart';
import 'admin/admin_dashboard_screen.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAjZNNNE4A_KDKH64hccKN4sW8BUEqZApk",
        authDomain: "promptguard-d1559.firebaseapp.com",
        projectId: "promptguard-d1559",
        storageBucket: "promptguard-d1559.firebasestorage.app",
        messagingSenderId: "622915739922",
        appId: "1:622915739922:web:f116ab22ecbd9d5c8ed3cb",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BurgerProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
      ],
      child: const SaadFoodAdminApp(),
    ),
  );
}

class SaadFoodAdminApp extends StatelessWidget {
  const SaadFoodAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'SaadFood Admin',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFf06626),
          surface: const Color(0xFFFFFaf1),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFaf1),
        useMaterial3: true,
      ),
      // If not authenticated or not admin, show login
      home: authProvider.isAuthenticated && authProvider.user?.email == 'admin@saadfood.com'
          ? const AdminDashboardScreen()
          : const LoginScreen(),
    );
  }
}
