import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onProfileTap,
    this.profileImageUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: false,
      actions: [
        if (profileImageUrl != null)
          GestureDetector(
            onTap: onProfileTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl!),
                radius: 20,
              ),
            ),
          ),
        if (profileImageUrl == null)
          IconButton(
            onPressed: onProfileTap,
            icon:
                Icon(Icons.account_circle, color: Colors.green[700], size: 30),
          ),
      ],
    );
  }
}
