// lib/src/screens/community/community_screen.dart

import 'package:flutter/material.dart';
import 'package:health_nest/src/constants/app_colors.dart';
import 'package:health_nest/src/models/comment_model.dart';
import 'package:health_nest/src/models/post_model.dart';
import 'package:health_nest/src/providers/community_provider.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final Map<String, bool> _commentSectionVisibility = {};

  @override
  void initState() {
    super.initState();
    // CommunityProvider stream handled in constructor
  }

  void _createPost() {
    if (_postController.text.isEmpty) return;

    final communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    communityProvider.addPost(_postController.text, context);

    _postController.clear();
    FocusScope.of(context).unfocus(); // Hide keyboard after posting
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPostInputCard(userProvider),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: communityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : communityProvider.posts.isEmpty
                    ? const Center(
                        child: Text(
                          'No posts yet! Be the first to share.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: communityProvider.posts.length,
                        itemBuilder: (context, index) {
                          final post = communityProvider.posts[index];
                          return _buildPostCard(
                              post, userProvider, communityProvider);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInputCard(UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _postController,
                decoration: const InputDecoration(
                  hintText: 'Share your progress or ask a question...',
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _createPost,
              icon: const Icon(Icons.send_rounded, color: AppColors.community),
              tooltip: 'Post',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post, UserProvider userProvider,
      CommunityProvider communityProvider) {
    final bool isLiked =
        userProvider.user?.likedPosts.contains(post.id) ?? false;
    final bool isCommentSectionVisible =
        _commentSectionVisibility[post.id] ?? false;
    final commentController = TextEditingController();

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
                CircleAvatar(
                  radius: 20,
                  child: Text(
                    post.userName.isNotEmpty ? post.userName[0] : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${post.timestamp.toDate().hour}:${post.timestamp.toDate().minute}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final user = userProvider.user;
                    if (user != null) {
                      // Updated toggleLike call with userProvider
                      communityProvider.toggleLike(
                          post.id, user.id, userProvider);
                    }
                  },
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    size: 20,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),
                ),
                Text('${post.likes} likes'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _commentSectionVisibility[post.id] =
                          !isCommentSectionVisible;
                    });
                  },
                  child: Text(
                    isCommentSectionVisible
                        ? 'Hide Comments'
                        : 'View all ${post.comments} comments',
                    style: TextStyle(color: AppColors.community),
                  ),
                ),
              ],
            ),
            if (isCommentSectionVisible)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: _buildCommentSection(
                    post.id, communityProvider, commentController),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(
      String postId,
      CommunityProvider communityProvider,
      TextEditingController commentController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<CommentModel>>(
          stream: communityProvider.getCommentsForPost(postId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No comments yet.',
                  style: TextStyle(color: Colors.grey));
            }
            final comments = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text(
                          comment.userName.isNotEmpty
                              ? comment.userName[0]
                              : 'U',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(comment.content,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    communityProvider.addComment(postId, value, context);
                    commentController.clear();
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  communityProvider.addComment(
                      postId, commentController.text, context);
                  commentController.clear();
                }
              },
              icon: const Icon(Icons.send),
              color: AppColors.community,
            ),
          ],
        ),
      ],
    );
  }
}
