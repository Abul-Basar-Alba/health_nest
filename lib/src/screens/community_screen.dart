// lib/src/screens/community_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_nest/src/models/comment_model.dart';
import 'package:health_nest/src/models/post_model.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/community_service.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _communityService = CommunityService();
  final Map<String, bool> _commentSectionVisibility = {};
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showCreatePostDialog(dynamic currentUser) {
    if (currentUser == null) return;

    final TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: currentUser.profileImageUrl != null
                          ? NetworkImage(currentUser.profileImageUrl!)
                          : null,
                      backgroundColor: Colors.teal[100],
                      child: currentUser.profileImageUrl == null
                          ? const Icon(Icons.person, color: Colors.teal)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentUser.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: postController,
                  autofocus: true,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (postController.text.trim().isEmpty) return;

                      final newPost = PostModel(
                        id: '',
                        userId: currentUser.id,
                        userName: currentUser.name,
                        userAvatar: currentUser.profileImageUrl ?? '',
                        content: postController.text.trim(),
                        reactions: {},
                        comments: 0,
                        timestamp: Timestamp.now(),
                      );

                      await _communityService.addPost(newPost);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post shared!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => _showCreatePostDialog(currentUser),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: currentUser?.profileImageUrl != null
                        ? NetworkImage(currentUser!.profileImageUrl!)
                        : null,
                    backgroundColor: Colors.teal[100],
                    child: currentUser?.profileImageUrl == null
                        ? const Icon(Icons.person, color: Colors.teal, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        "What's on your mind, ${currentUser?.name.split(' ').first ?? 'User'}?",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: _communityService.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data![index];
                    return _buildPostCard(post, currentUser);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post, dynamic currentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.userAvatar.isNotEmpty
                      ? NetworkImage(post.userAvatar)
                      : null,
                  backgroundColor: Colors.teal[100],
                  child: post.userAvatar.isEmpty
                      ? const Icon(Icons.person, color: Colors.teal)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getTimeAgo(post.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 12),
          if (post.totalReactions > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${post.totalReactions} reactions',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: currentUser != null
                        ? () {
                            _communityService.toggleLike(
                                post.id, currentUser.id);
                          }
                        : null,
                    icon: Icon(
                      Icons.thumb_up,
                      size: 20,
                      color: currentUser?.likedPosts.contains(post.id) == true
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    label: Text(
                      'Like',
                      style: TextStyle(
                        color: currentUser?.likedPosts.contains(post.id) == true
                            ? Colors.blue
                            : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _commentSectionVisibility[post.id] =
                            !(_commentSectionVisibility[post.id] ?? false);
                      });
                    },
                    icon:
                        Icon(Icons.comment, size: 20, color: Colors.grey[600]),
                    label: Text(
                      'Comment',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_commentSectionVisibility[post.id] == true)
            _buildCommentSection(post, currentUser),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildCommentSection(PostModel post, dynamic currentUser) {
    _commentControllers.putIfAbsent(
      post.id,
      () => TextEditingController(),
    );

    final controller = _commentControllers[post.id]!;

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<CommentModel>>(
            stream: _communityService.getCommentsStream(post.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.teal,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final comments = snapshot.data!;
              if (comments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No comments yet. Be the first!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                );
              }

              return Column(
                children: comments.map((comment) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: comment.userAvatar.isNotEmpty
                              ? NetworkImage(comment.userAvatar)
                              : null,
                          backgroundColor: Colors.teal[100],
                          child: comment.userAvatar.isEmpty
                              ? const Icon(Icons.person,
                                  color: Colors.teal, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comment.content,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getTimeAgo(comment.timestamp.toDate()),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          if (currentUser != null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle:
                          TextStyle(fontSize: 14, color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        final newComment = CommentModel(
                          id: '',
                          postId: post.id,
                          userId: currentUser.id,
                          userName: currentUser.name,
                          userAvatar: currentUser.profileImageUrl ?? '',
                          content: value.trim(),
                          timestamp: Timestamp.now(),
                        );
                        _communityService.addComment(newComment);
                        controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      final newComment = CommentModel(
                        id: '',
                        postId: post.id,
                        userId: currentUser.id,
                        userName: currentUser.name,
                        userAvatar: currentUser.profileImageUrl ?? '',
                        content: controller.text.trim(),
                        timestamp: Timestamp.now(),
                      );
                      _communityService.addComment(newComment);
                      controller.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.teal),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
