import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../providers/user_provider.dart';
import '../../services/community_service.dart';

class PremiumCommunityScreen extends StatefulWidget {
  const PremiumCommunityScreen({super.key});

  @override
  State<PremiumCommunityScreen> createState() => _PremiumCommunityScreenState();
}

class _PremiumCommunityScreenState extends State<PremiumCommunityScreen>
    with SingleTickerProviderStateMixin {
  final CommunityService _communityService = CommunityService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // FB-style "What's on your mind?" section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Post creation box
                GestureDetector(
                  onTap: () => _showCreatePostDialog(currentUser),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            const Color(0xFF0084FF).withOpacity(0.1),
                        backgroundImage: currentUser?.profileImageUrl != null
                            ? NetworkImage(currentUser!.profileImageUrl!)
                            : null,
                        child: currentUser?.profileImageUrl == null
                            ? const Icon(Icons.person,
                                color: Color(0xFF0084FF), size: 22)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(24),
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
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                // Tabs
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _tabController.animateTo(0);
                          });
                        },
                        icon: Icon(
                          Icons.feed,
                          size: 22,
                          color: _tabController.index == 0
                              ? const Color(0xFF0084FF)
                              : Colors.grey[600],
                        ),
                        label: Text(
                          'Feed',
                          style: TextStyle(
                            color: _tabController.index == 0
                                ? const Color(0xFF0084FF)
                                : Colors.grey[700],
                            fontSize: 15,
                            fontWeight: _tabController.index == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.grey[300]),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _tabController.animateTo(1);
                          });
                        },
                        icon: Icon(
                          Icons.people,
                          size: 22,
                          color: _tabController.index == 1
                              ? const Color(0xFF0084FF)
                              : Colors.grey[600],
                        ),
                        label: Text(
                          'Members',
                          style: TextStyle(
                            color: _tabController.index == 1
                                ? const Color(0xFF0084FF)
                                : Colors.grey[700],
                            fontSize: 15,
                            fontWeight: _tabController.index == 1
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedTab(currentUser),
                _buildMembersTab(currentUser),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Feed Tab
  Widget _buildFeedTab(dynamic currentUser) {
    return StreamBuilder<List<PostModel>>(
      stream: _communityService.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0084FF),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share what\'s on your mind!',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildPostCard(snapshot.data![index], currentUser);
          },
        );
      },
    );
  }

  // Members Tab
  Widget _buildMembersTab(dynamic currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No members found'));
        }

        final members = snapshot.data!.docs
            .where((doc) => doc.id != currentUser?.id)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                  backgroundImage: member['profileImageUrl'] != null
                      ? NetworkImage(member['profileImageUrl'])
                      : null,
                  child: member['profileImageUrl'] == null
                      ? Text(
                          (member['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF667EEA),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  member['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  member['email'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF48BB78).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Color(0xFF48BB78),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Post Card with FB-style reactions
  Widget _buildPostCard(PostModel post, dynamic currentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
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
                  backgroundColor: const Color(0xFF0084FF).withOpacity(0.1),
                  backgroundImage: post.userAvatar.isNotEmpty
                      ? NetworkImage(post.userAvatar)
                      : null,
                  child: post.userAvatar.isEmpty
                      ? Text(
                          post.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0084FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        )
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
                        timeago.format(post.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),

          const SizedBox(height: 12),

          if (post.imageUrl != null)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          // Reactions Count
          if (post.totalReactions > 0 || post.comments > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (post.totalReactions > 0)
                    Row(
                      children: [
                        _buildReactionIcons(post.reactions),
                        const SizedBox(width: 6),
                        Text(
                          '${post.totalReactions}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                  if (post.comments > 0)
                    Text(
                      '${post.comments} comment${post.comments > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),

          Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),

          // Action Buttons - FIXED OVERFLOW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildReactionButton(post, currentUser),
                ),
                Expanded(
                  child: _buildCommentButton(post, currentUser),
                ),
                Expanded(
                  child: _buildShareButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reaction Icons Display
  Widget _buildReactionIcons(Map<String, int> reactions) {
    final reactionEmojis = {
      'like': '👍',
      'love': '❤️',
      'haha': '😂',
      'wow': '😮',
      'sad': '😢',
      'angry': '😠',
    };

    final topReactions = reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: topReactions.take(3).map((entry) {
        return Container(
          margin: const EdgeInsets.only(right: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            reactionEmojis[entry.key] ?? '👍',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  // Reaction Button with FB-style picker
  Widget _buildReactionButton(PostModel post, dynamic currentUser) {
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
              color: hasReacted ? const Color(0xFF0084FF) : Colors.grey[700],
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

  // Comment Button
  Widget _buildCommentButton(PostModel post, dynamic currentUser) {
    return TextButton.icon(
      onPressed: () => _showCommentsSheet(post, currentUser),
      icon: Icon(Icons.comment_outlined, size: 20, color: Colors.grey[700]),
      label: Text(
        'Comment',
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  // Share Button
  Widget _buildShareButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(Icons.share_outlined, size: 20, color: Colors.grey[700]),
      label: Text(
        'Share',
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  // Show Reaction Picker (FB-style)
  void _showReactionPicker(
      BuildContext context, PostModel post, dynamic currentUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final reactions = [
          {'type': 'like', 'emoji': '👍', 'label': 'Like'},
          {'type': 'love', 'emoji': '❤️', 'label': 'Love'},
          {'type': 'haha', 'emoji': '😂', 'label': 'Haha'},
          {'type': 'wow', 'emoji': '😮', 'label': 'Wow'},
          {'type': 'sad', 'emoji': '😢', 'label': 'Sad'},
          {'type': 'angry', 'emoji': '😠', 'label': 'Angry'},
        ];

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: reactions.map((reaction) {
                return GestureDetector(
                  onTap: () {
                    _communityService.toggleReaction(
                        post.id, currentUser.id, reaction['type'] as String);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F5),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            reaction['emoji'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reaction['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
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
        );
      },
    );
  }

  // Show Comments Sheet
  void _showCommentsSheet(PostModel post, dynamic currentUser) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey[200]),

                  // Comments List
                  Expanded(
                    child: StreamBuilder<List<CommentModel>>(
                      stream: _communityService.getCommentsStream(post.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment_outlined,
                                    size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final comment = snapshot.data![index];
                            return _buildCommentItem(comment);
                          },
                        );
                      },
                    ),
                  ),

                  // Comment Input
                  Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              const Color(0xFF667EEA).withOpacity(0.1),
                          child: Text(
                            (currentUser.name ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    const BorderSide(color: Color(0xFF667EEA)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            if (commentController.text.trim().isEmpty) return;

                            final comment = CommentModel(
                              id: '',
                              postId: post.id,
                              userId: currentUser.id,
                              userName: currentUser.name,
                              content: commentController.text.trim(),
                              timestamp: Timestamp.now(),
                            );

                            await _communityService.addComment(comment);
                            commentController.clear();
                          },
                          icon:
                              const Icon(Icons.send, color: Color(0xFF667EEA)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Comment Item
  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
            child: Text(
              comment.userName[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF667EEA),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeago.format(comment.timestamp.toDate()),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Create Post Dialog
  void _showCreatePostDialog(dynamic currentUser) {
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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            const Color(0xFF0084FF).withOpacity(0.1),
                        backgroundImage: currentUser?.profileImageUrl != null
                            ? NetworkImage(currentUser!.profileImageUrl!)
                            : null,
                        child: currentUser?.profileImageUrl == null
                            ? const Icon(Icons.person,
                                color: Color(0xFF0084FF), size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentUser?.name ?? 'User',
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
                // Text input
                Padding(
                  padding: const EdgeInsets.all(16),
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
                // Post button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (postController.text.trim().isEmpty) return;

                        final post = PostModel(
                          id: '',
                          userId: currentUser.id,
                          userName: currentUser.name,
                          userAvatar: currentUser.profileImageUrl ?? '',
                          content: postController.text.trim(),
                          timestamp: Timestamp.now(),
                        );

                        await _communityService.addPost(post);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post shared successfully!'),
                              backgroundColor: Color(0xFF0084FF),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0084FF),
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
    );
  }
}

// Fix for ClipRRectangle typo
class ClipRRectangle extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;

  const ClipRRectangle({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}
