// lib/src/screens/admin_panel_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/admin_message_service.dart';
import 'admin_chat_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: The service name does not change, only the collection it targets.
    final firestoreService = AdminMessageService();
    final currentUser = Provider.of<UserProvider>(context).user;

    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Access Denied: You are not an admin.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load users.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              if (user.id == currentUser.id) {
                return const SizedBox.shrink();
              }
              return _buildUserTile(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing:
            Icon(user.isAdmin ? Icons.verified_user : Icons.person_outline),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminChatScreen(
                recipientId: user.id,
                recipientName: user.name,
              ),
            ),
          );
        },
      ),
    );
  }
}
