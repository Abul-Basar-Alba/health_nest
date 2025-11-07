// lib/src/screens/community_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_nest/src/models/comment_model.dart';
import 'package:health_nest/src/models/post_model.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/community_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final CommunityService _communityService = CommunityService();
  final Map<String, bool> _commentSectionVisibility = {};
  final Map<String, TextEditingController> _commentControllers = {};
  late TabController _tabController;
  String _selectedCategory = 'all'; // 'all', 'pregnancy', 'medicine', 'fitness'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedCategory = 'all';
            break;
          case 1:
            _selectedCategory = 'pregnancy';
            break;
          case 2:
            _selectedCategory = 'medicine';
            break;
          case 3:
            _selectedCategory = 'fitness';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showCreatePostDialog(dynamic currentUser) {
    if (currentUser == null) return;

    final TextEditingController postController = TextEditingController();
    String selectedCategory =
        _selectedCategory == 'all' ? 'general' : _selectedCategory;
    List<String> selectedTags = [];
    String? pregnancyWeek;

    // Pregnancy topics
    final pregnancyTopics = [
      'Symptoms',
      'Nutrition',
      'Exercise',
      'Questions',
      'Experience',
      'Doctor Visits',
      'Baby Shopping',
      'Labor Stories',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
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
                  // Category Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.category,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Category:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('General'),
                                selected: selectedCategory == 'general',
                                onSelected: (selected) {
                                  setModalState(() {
                                    selectedCategory = 'general';
                                    selectedTags.clear();
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('🤰 Pregnancy'),
                                selected: selectedCategory == 'pregnancy',
                                onSelected: (selected) {
                                  setModalState(() {
                                    selectedCategory = 'pregnancy';
                                    selectedTags.clear();
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('💊 Medicine'),
                                selected: selectedCategory == 'medicine',
                                onSelected: (selected) {
                                  setModalState(() {
                                    selectedCategory = 'medicine';
                                    selectedTags.clear();
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('💪 Fitness'),
                                selected: selectedCategory == 'fitness',
                                onSelected: (selected) {
                                  setModalState(() {
                                    selectedCategory = 'fitness';
                                    selectedTags.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pregnancy Topics (only for pregnancy category)
                  if (selectedCategory == 'pregnancy')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.topic, size: 20, color: Colors.pink),
                              SizedBox(width: 8),
                              Text('Topics:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pregnancyTopics.map((topic) {
                              final isSelected = selectedTags.contains(topic);
                              return FilterChip(
                                label: Text(topic),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      selectedTags.add(topic);
                                    } else {
                                      selectedTags.remove(topic);
                                    }
                                  });
                                },
                                selectedColor: Colors.pink[100],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: postController,
                      autofocus: true,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: selectedCategory == 'pregnancy'
                            ? "Share your pregnancy journey..."
                            : "What's on your mind?",
                        border: InputBorder.none,
                        hintStyle: const TextStyle(fontSize: 16),
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

                          String? dueDate;
                          if (selectedCategory == 'pregnancy') {
                            // Try to get due date from pregnancy tracker
                            try {
                              final pregnancyDoc = await FirebaseFirestore
                                  .instance
                                  .collection('pregnancies')
                                  .where('userId', isEqualTo: currentUser.id)
                                  .where('isActive', isEqualTo: true)
                                  .limit(1)
                                  .get();

                              if (pregnancyDoc.docs.isNotEmpty) {
                                final pregnancyData =
                                    pregnancyDoc.docs.first.data();
                                dueDate = pregnancyData['dueDate'];
                                pregnancyWeek =
                                    pregnancyData['currentWeek']?.toString();
                              }
                            } catch (e) {
                              print('Error fetching pregnancy data: $e');
                            }
                          }

                          final newPost = PostModel(
                            id: '',
                            userId: currentUser.id,
                            userName: currentUser.name,
                            userAvatar: currentUser.profileImageUrl ?? '',
                            content: postController.text.trim(),
                            reactions: {},
                            comments: 0,
                            timestamp: Timestamp.now(),
                            category: selectedCategory,
                            pregnancyDueDate: dueDate,
                            pregnancyWeek: pregnancyWeek,
                            tags: selectedTags,
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
                          backgroundColor: selectedCategory == 'pregnancy'
                              ? Colors.pink
                              : Colors.teal,
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
          // Category Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: '🌐 All'),
                Tab(text: '🤰 Pregnancy'),
                Tab(text: '💊 Medicine'),
                Tab(text: '💪 Fitness'),
              ],
            ),
          ),
          // Create post section
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
                        _selectedCategory == 'pregnancy'
                            ? "Share your pregnancy journey..."
                            : "What's on your mind, ${currentUser?.name.split(' ').first ?? 'User'}?",
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
            child: _buildPostsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    // Always get all posts, then filter client-side
    // This avoids Firestore index requirement
    return StreamBuilder<List<PostModel>>(
      stream: _communityService.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (snapshot.hasError) {
          print('Error loading posts: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading posts',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Client-side filtering
        List<PostModel> filteredPosts = snapshot.data ?? [];
        if (_selectedCategory != 'all') {
          filteredPosts = filteredPosts
              .where((post) => post.category == _selectedCategory)
              .toList();
        }

        if (filteredPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedCategory == 'pregnancy'
                      ? Icons.pregnant_woman
                      : Icons.forum_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedCategory == 'pregnancy'
                      ? 'No pregnancy posts yet'
                      : 'No posts yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share something!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final currentUser = userProvider.user;

        return ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            final post = filteredPosts[index];
            return _buildPostCard(post, currentUser);
          },
        );
      },
    );
  }

  Widget _buildPostCard(PostModel post, dynamic currentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatar.isNotEmpty
                      ? NetworkImage(post.userAvatar)
                      : null,
                  backgroundColor: Colors.teal[100],
                  child: post.userAvatar.isEmpty
                      ? const Icon(Icons.person, color: Colors.teal, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (post.category == 'pregnancy' &&
                              post.pregnancyWeek != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink[200]!),
                              ),
                              child: Text(
                                '🤰 Week ${post.pregnancyWeek}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.pink[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTimestamp(post.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (post.category != 'general') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(post.category),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getCategoryLabel(post.category),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Tags
                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: post.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Post Content
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
          if (post.totalReactions > 0 || post.comments > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (post.totalReactions > 0)
                    Row(
                      children: [
                        if (post.reactions.isNotEmpty)
                          ...post.reactions.keys.take(3).map((reactionType) {
                            final emojis = {
                              'like': '👍',
                              'love': '❤️',
                              'haha': '😂',
                              'wow': '😮',
                              'sad': '😢',
                              'angry': '😠',
                            };
                            return Container(
                              margin: const EdgeInsets.only(right: 2),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(emojis[reactionType] ?? '👍',
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }),
                        const SizedBox(width: 6),
                        Text(
                          '${post.totalReactions}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                  if (post.comments > 0)
                    Text(
                      '${post.comments} comment${post.comments > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                ],
              ),
            ),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildReactionButton(post, currentUser),
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
                      'Comment${post.comments > 0 ? ' (${post.comments})' : ''}',
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

  // Build reaction button with Facebook-style picker
  Widget _buildReactionButton(PostModel post, dynamic currentUser) {
    if (currentUser == null) return const SizedBox();

    return FutureBuilder<String?>(
      future: _communityService.getUserReaction(post.id, currentUser.id),
      builder: (context, snapshot) {
        final userReaction = snapshot.data;
        final reactionEmojis = {
          'like': '👍',
          'love': '❤️',
          'haha': '😂',
          'wow': '😮',
          'sad': '😢',
          'angry': '😠',
        };

        final hasReacted = userReaction != null;

        return TextButton.icon(
          onPressed: () =>
              _communityService.toggleReaction(post.id, currentUser.id, 'like'),
          onLongPress: () => _showReactionPicker(context, post, currentUser),
          icon: Text(
            hasReacted ? reactionEmojis[userReaction]! : '👍',
            style: const TextStyle(fontSize: 18),
          ),
          label: Text(
            hasReacted
                ? userReaction[0].toUpperCase() + userReaction.substring(1)
                : 'Like',
            style: TextStyle(
              color: hasReacted ? Colors.teal : Colors.grey[700],
              fontWeight: hasReacted ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      },
    );
  }

  // Show reaction picker
  void _showReactionPicker(
      BuildContext context, PostModel post, dynamic currentUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your reaction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {'emoji': '👍', 'label': 'Like', 'type': 'like'},
                  {'emoji': '❤️', 'label': 'Love', 'type': 'love'},
                  {'emoji': '😂', 'label': 'Haha', 'type': 'haha'},
                  {'emoji': '😮', 'label': 'Wow', 'type': 'wow'},
                  {'emoji': '😢', 'label': 'Sad', 'type': 'sad'},
                  {'emoji': '😠', 'label': 'Angry', 'type': 'angry'},
                ].map((reaction) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        _communityService.toggleReaction(post.id,
                            currentUser.id, reaction['type'] as String);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              reaction['emoji'] as String,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reaction['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
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

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'pregnancy':
        return Colors.pink;
      case 'medicine':
        return Colors.blue;
      case 'fitness':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'pregnancy':
        return '🤰 PREGNANCY';
      case 'medicine':
        return '💊 MEDICINE';
      case 'fitness':
        return '💪 FITNESS';
      default:
        return 'GENERAL';
    }
  }
}
