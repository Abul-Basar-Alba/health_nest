import 'package:flutter/material.dart';
import 'package:health_nest/src/constants/app_colors.dart';
import 'package:health_nest/src/models/post_model.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/firestore_service.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _postController = TextEditingController();

  void _createPost() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (_postController.text.isEmpty || user == null) return;

    final newPost = PostModel(
      id: '',
      userId: user.id,
      username: user.name,
      content: _postController.text,
      likes: 0,
      timestamp: DateTime.now(),
    );

    try {
      await _firestoreService.addPost(newPost);
      _postController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPostInputCard(),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: _firestoreService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No posts yet! Be the first to share.'));
                }
                final posts = snapshot.data!;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPostCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInputCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: 'Share your progress or ask a question...',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _createPost,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.community,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Placeholder for user avatar
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${post.timestamp.hour}:${post.timestamp.minute}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Logic to handle liking a post
                      },
                      icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                    ),
                    Text('${post.likes}'),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Logic to navigate to comments section
                  },
                  child: const Text('Comments'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
