// lib/src/screens/pregnancy/family_support_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pregnancy_family_member_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';

class FamilySupportScreen extends StatefulWidget {
  const FamilySupportScreen({super.key});

  @override
  State<FamilySupportScreen> createState() => _FamilySupportScreenState();
}

class _FamilySupportScreenState extends State<FamilySupportScreen> {
  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final pregnancyProvider =
        Provider.of<PregnancyProvider>(context, listen: false);

    if (pregnancyProvider.activePregnancy != null) {
      await pregnancyProvider
          .loadFamilyMembers(pregnancyProvider.activePregnancy!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC), // Cream
      appBar: AppBar(
        title: Consumer<PregnancyProvider>(
          builder: (context, provider, _) => Text(
            provider.isBangla ? 'পরিবার সাপোর্ট' : 'Family Support',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFFF9800), // Orange
        elevation: 0,
      ),
      body: Consumer<PregnancyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Card
              _buildInfoCard(provider),

              const SizedBox(height: 24),

              // Family Members List
              Text(
                provider.isBangla ? 'পরিবারের সদস্য' : 'Family Members',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (provider.familyMembers.isEmpty)
                _buildEmptyState(provider)
              else
                ...provider.familyMembers
                    .map((member) => _buildMemberCard(member, provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context),
        backgroundColor: const Color(0xFFFF9800),
        icon: const Icon(Icons.person_add),
        label: Consumer<PregnancyProvider>(
          builder: (context, provider, _) => Text(
            provider.isBangla ? 'সদস্য যোগ করুন' : 'Add Member',
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(PregnancyProvider provider) {
    return Card(
      color: const Color(0xFFFF9800).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.family_restroom,
                  color: Color(0xFFFF9800),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.isBangla
                        ? 'পরিবারের সাথে শেয়ার করুন'
                        : 'Share with Family',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              provider.isBangla
                  ? 'আপনার পরিবারের সদস্যদের যোগ করুন যাতে তারা আপনার গর্ভাবস্থা ট্র্যাক করতে এবং গুরুত্বপূর্ণ নোটিফিকেশন পেতে পারে।'
                  : 'Add your family members so they can track your pregnancy and receive important notifications.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(PregnancyProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.isBangla
                  ? 'কোনো পরিবারের সদস্য নেই'
                  : 'No family members added',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.isBangla
                  ? 'আপনার পরিবারের সদস্যদের যোগ করুন'
                  : 'Add your family members to share updates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    PregnancyFamilyMemberModel member,
    PregnancyProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF9800).withOpacity(0.2),
          radius: 30,
          child: Text(
            member.memberName[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
        ),
        title: Text(
          member.memberName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.favorite, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(member.getRelationshipName(provider.isBangla)),
              ],
            ),
            if (member.phoneNumber != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14),
                  const SizedBox(width: 4),
                  Text(member.phoneNumber!),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  member.receiveNotifications
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  size: 14,
                  color:
                      member.receiveNotifications ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isBangla
                      ? (member.receiveNotifications
                          ? 'নোটিফিকেশন চালু'
                          : 'নোটিফিকেশন বন্ধ')
                      : (member.receiveNotifications
                          ? 'Notifications On'
                          : 'Notifications Off'),
                  style: TextStyle(
                    color: member.receiveNotifications
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditMemberDialog(context, member);
            } else if (value == 'remove') {
              _confirmRemove(context, member, provider);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(provider.isBangla ? 'সম্পাদনা' : 'Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(provider.isBangla ? 'সরান' : 'Remove'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRelationship = 'husband';
    bool receiveNotifications = true;
    List<String> selectedTypes = [
      'checkup',
      'emergency',
      'milestone',
      'reminder'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            provider.isBangla ? 'সদস্য যোগ করুন' : 'Add Family Member',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'নাম' : 'Name',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Relationship
                DropdownButtonFormField<String>(
                  initialValue: selectedRelationship,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'সম্পর্ক' : 'Relationship',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.family_restroom),
                  ),
                  items: PregnancyFamilyMemberModel.relationshipsEN.keys
                      .map((rel) => DropdownMenuItem(
                            value: rel,
                            child: Text(
                              provider.isBangla
                                  ? PregnancyFamilyMemberModel
                                      .relationshipsBN[rel]!
                                  : PregnancyFamilyMemberModel
                                      .relationshipsEN[rel]!,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRelationship = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'ফোন নম্বর' : 'Phone Number',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),

                // Email (optional)
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: provider.isBangla
                        ? 'ইমেইল (ঐচ্ছিক)'
                        : 'Email (Optional)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                // Notifications toggle
                SwitchListTile(
                  title: Text(
                    provider.isBangla
                        ? 'নোটিফিকেশন পাঠান'
                        : 'Send Notifications',
                  ),
                  value: receiveNotifications,
                  onChanged: (value) {
                    setState(() => receiveNotifications = value);
                  },
                  activeThumbColor: const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isBangla ? 'নাম প্রয়োজন' : 'Name is required',
                      ),
                    ),
                  );
                  return;
                }

                final member = PregnancyFamilyMemberModel(
                  id: '',
                  pregnancyId: provider.activePregnancy!.id,
                  userId: authProvider.user!.uid,
                  memberName: nameController.text.trim(),
                  relationship: selectedRelationship,
                  phoneNumber: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  receiveNotifications: receiveNotifications,
                  notificationTypes: selectedTypes,
                );

                await provider.addFamilyMember(member);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
              child: Text(provider.isBangla ? 'যোগ করুন' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog(
    BuildContext context,
    PregnancyFamilyMemberModel member,
  ) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    final nameController = TextEditingController(text: member.memberName);
    final phoneController =
        TextEditingController(text: member.phoneNumber ?? '');
    final emailController = TextEditingController(text: member.email ?? '');
    String selectedRelationship = member.relationship;
    bool receiveNotifications = member.receiveNotifications;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            provider.isBangla ? 'সদস্য সম্পাদনা' : 'Edit Member',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'নাম' : 'Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRelationship,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'সম্পর্ক' : 'Relationship',
                    border: const OutlineInputBorder(),
                  ),
                  items: PregnancyFamilyMemberModel.relationshipsEN.keys
                      .map((rel) => DropdownMenuItem(
                            value: rel,
                            child: Text(
                              provider.isBangla
                                  ? PregnancyFamilyMemberModel
                                      .relationshipsBN[rel]!
                                  : PregnancyFamilyMemberModel
                                      .relationshipsEN[rel]!,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRelationship = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'ফোন' : 'Phone',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    provider.isBangla ? 'নোটিফিকেশন' : 'Notifications',
                  ),
                  value: receiveNotifications,
                  onChanged: (value) {
                    setState(() => receiveNotifications = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedMember = member.copyWith(
                  memberName: nameController.text.trim(),
                  relationship: selectedRelationship,
                  phoneNumber: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  receiveNotifications: receiveNotifications,
                );

                await provider.updateFamilyMember(updatedMember);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
              child: Text(provider.isBangla ? 'আপডেট' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    PregnancyFamilyMemberModel member,
    PregnancyProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.isBangla ? 'নিশ্চিত করুন' : 'Confirm'),
        content: Text(
          provider.isBangla
              ? 'আপনি কি ${member.memberName} সরাতে চান?'
              : 'Do you want to remove ${member.memberName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(provider.isBangla ? 'না' : 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeFamilyMember(member.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(provider.isBangla ? 'হ্যাঁ' : 'Yes'),
          ),
        ],
      ),
    );
  }
}
