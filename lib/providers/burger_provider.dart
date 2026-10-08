import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/burger.dart';

class BurgerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Burger> _burgers = [];

  List<Burger> get burgers => [..._burgers];

  // Stream to get burgers from Firestore in real-time
  Stream<List<Burger>> get burgersStream {
    return _firestore.collection('burgers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Burger.fromMap(data);
      }).toList();
    });
  }

  // Upload Image to Firebase Storage and get URL
  Future<String?> uploadImage(dynamic imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('burger_images').child('$fileName.jpg');
      
      if (kIsWeb) {
        // For Web, imageFile is Uint8List
        await ref.putData(imageFile);
      } else {
        // For Mobile, imageFile is File
        await ref.putFile(imageFile as File);
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Optional: Upload initial dummy data to Firestore if collection is empty
  Future<void> uploadDummyData() async {
    try {
      final snapshot = await _firestore.collection('burgers').get();
      if (snapshot.docs.isEmpty) {
        for (var burger in dummyBurgers) {
          await _firestore.collection('burgers').doc(burger.id).set(burger.toMap());
        }
        debugPrint('Initial dummy data uploaded successfully!');
      }
    } catch (e) {
      debugPrint('Error uploading dummy data: $e');
    }
  }

  // Admin: Add a new burger
  Future<void> addBurger(Burger burger) async {
    try {
      // Use Firestore generated ID if none provided, or use provided one
      final docRef = burger.id.isEmpty 
          ? _firestore.collection('burgers').doc() 
          : _firestore.collection('burgers').doc(burger.id);
      
      final newBurger = Burger(
        id: docRef.id,
        name: burger.name,
        description: burger.description,
        price: burger.price,
        rating: burger.rating,
        imageUrl: burger.imageUrl,
        category: burger.category,
      );

      await docRef.set(newBurger.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding burger: $e');
      rethrow;
    }
  }

  // Admin: Delete a burger
  Future<void> deleteBurger(String id) async {
    try {
      await _firestore.collection('burgers').doc(id).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting burger: $e');
      rethrow;
    }
  }
}
