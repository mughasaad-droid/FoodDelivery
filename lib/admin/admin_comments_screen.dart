import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/comment_provider.dart';

class AdminCommentsScreen extends StatelessWidget {
  const AdminCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1),
      appBar: AppBar(
        title: const Text('Customer Feedback', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFf06626)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () => _showClearDialog(context, commentProvider),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<List<CommentItem>>(
        stream: commentProvider.getCommentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFf06626)));
          }

          final comments = snapshot.data ?? [];
          if (comments.isEmpty) {
            return const Center(child: Text('No feedback yet.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final date = DateFormat('MMM dd, yyyy • h:mm a').format(comment.timestamp);

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              comment.userEmail,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf06626)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        comment.comment,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, CommentProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All?'),
        content: const Text('Are you sure you want to delete all customer feedback?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.clearAllComments();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
