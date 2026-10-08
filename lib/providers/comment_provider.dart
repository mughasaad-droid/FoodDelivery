import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentItem {
  final String id;
  final String userEmail;
  final String comment;
  final DateTime timestamp;

  CommentItem({
    required this.id,
    required this.userEmail,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CommentItem.fromMap(String id, Map<String, dynamic> map) {
    return CommentItem(
      id: id,
      userEmail: map['userEmail'] ?? 'Anonymous',
      comment: map['comment'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class CommentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send comment to Firestore
  Future<void> sendComment(String email, String comment) async {
    try {
      await _firestore.collection('comments').add({
        'userEmail': email,
        'comment': comment,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error sending comment: $e');
      rethrow;
    }
  }

  // Stream comments for Admin
  Stream<List<CommentItem>> getCommentsStream() {
    return _firestore
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommentItem.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Clear all comments (Admin only)
  Future<void> clearAllComments() async {
    try {
      final snapshot = await _firestore.collection('comments').get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing comments: $e');
      rethrow;
    }
  }
}
