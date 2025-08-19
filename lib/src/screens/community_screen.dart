import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join the conversation!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _buildPostCard(
              context,
              username: 'Sarah_Healthy',
              profileImage: 'assets/images/sarah.jpg',
              postContent:
                  'Just hit my 10,000 steps goal for the fifth day in a row! So proud of myself! 💪 #StepChallenge',
              likes: 124,
              comments: 21,
            ),
            const SizedBox(height: 16),
            _buildPostCard(
              context,
              username: 'FitnessGuru',
              profileImage: 'assets/images/guru.jpg',
              postContent:
                  'Shared a new high-protein meal plan! Check it out and let me know what you think. #MealPrep #Nutrition',
              likes: 256,
              comments: 45,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action to create a new post
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening new post editor...')),
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Share Your Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context,
      {required String username,
      required String profileImage,
      required String postContent,
      required int likes,
      required int comments}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(profileImage),
                ),
                const SizedBox(width: 12),
                Text(
                  username,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              postContent,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_rounded,
                        size: 20, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text('$likes Likes'),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_rounded, size: 20, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$comments Comments'),
                  ],
                ),
                const Icon(Icons.share_rounded, color: Colors.green, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
