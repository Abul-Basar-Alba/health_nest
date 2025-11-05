import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/family_member_model.dart';
import '../providers/family_provider.dart';

class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});

  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMemberModel> _filteredMembers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      Provider.of<FamilyProvider>(context, listen: false)
          .initializeFamilyMembers(userId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, String userId) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredMembers = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = await Provider.of<FamilyProvider>(context, listen: false)
        .searchFamilyMembers(userId, query);

    setState(() {
      _filteredMembers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Profiles')),
        body: const Center(child: Text('Please sign in to continue')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Profiles'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<FamilyProvider>(context, listen: false)
                  .refresh(userId);
            },
          ),
        ],
      ),
      body: Consumer<FamilyProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(userId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final members =
              _isSearching ? _filteredMembers : provider.familyMembers;

          return Column(
            children: [
              // Statistics Card
              if (!_isSearching) _buildStatisticsCard(provider.statistics),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search family members...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('', userId);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (query) => _performSearch(query, userId),
                ),
              ),

              // Family Members List
              Expanded(
                child: members.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          return _buildFamilyMemberCard(
                            members[index],
                            provider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, userId),
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.people,
              'Total',
              stats['totalMembers']?.toString() ?? '0',
              Colors.blue,
            ),
            _buildStatItem(
              Icons.supervisor_account,
              'Caregivers',
              stats['totalCaregivers']?.toString() ?? '0',
              Colors.orange,
            ),
            _buildStatItem(
              Icons.notifications_active,
              'Notifications',
              stats['notificationEnabled']?.toString() ?? '0',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            _isSearching ? 'No family members found' : 'No family members yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Try a different search term'
                : 'Add your first family member',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (!_isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(
                context,
                FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Family Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009688),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyMemberCard(
    FamilyMemberModel member,
    FamilyProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddEditDialog(
          context,
          FirebaseAuth.instance.currentUser?.uid ?? '',
          member: member,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF009688).withOpacity(0.1),
                backgroundImage:
                    (member.photoUrl != null && member.photoUrl!.isNotEmpty)
                        ? NetworkImage(member.photoUrl!)
                        : null,
                child: (member.photoUrl == null || member.photoUrl!.isEmpty)
                    ? Text(
                        FamilyRelationship.getIcon(member.relationship),
                        style: const TextStyle(fontSize: 28),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (member.isCaregiver)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Caregiver',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member.relationship} • ${member.age} years old',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (member.email != null && member.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              member.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (member.phoneNumber != null &&
                        member.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            member.phoneNumber!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Notification Indicator
              if (member.canReceiveNotifications)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    String userId, {
    FamilyMemberModel? member,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddEditFamilyMemberDialog(
        userId: userId,
        member: member,
      ),
    );
  }
}

class AddEditFamilyMemberDialog extends StatefulWidget {
  final String userId;
  final FamilyMemberModel? member;

  const AddEditFamilyMemberDialog({
    super.key,
    required this.userId,
    this.member,
  });

  @override
  State<AddEditFamilyMemberDialog> createState() =>
      _AddEditFamilyMemberDialogState();
}

class _AddEditFamilyMemberDialogState extends State<AddEditFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _selectedRelationship = FamilyRelationship.all.first;
  DateTime? _dateOfBirth;
  bool _isCaregiver = false;
  bool _canReceiveNotifications = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _emailController = TextEditingController(text: widget.member?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.member?.phoneNumber ?? '');

    if (widget.member != null) {
      _selectedRelationship = widget.member!.relationship;
      _dateOfBirth = widget.member!.dateOfBirth;
      _isCaregiver = widget.member!.isCaregiver;
      _canReceiveNotifications = widget.member!.canReceiveNotifications;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF009688),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<FamilyProvider>(context, listen: false);

    final member = FamilyMemberModel(
      id: widget.member?.id ?? '',
      userId: widget.userId,
      name: _nameController.text.trim(),
      relationship: _selectedRelationship,
      dateOfBirth: _dateOfBirth!,
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      photoUrl: widget.member?.photoUrl ?? '',
      isCaregiver: _isCaregiver,
      canReceiveNotifications: _canReceiveNotifications,
      caregiverForUserIds: widget.member?.caregiverForUserIds ?? [],
      createdAt: widget.member?.createdAt ?? DateTime.now(),
      lastModified: DateTime.now(),
    );

    bool success;
    if (widget.member == null) {
      success = await provider.addFamilyMember(member);
    } else {
      success = await provider.updateFamilyMember(member);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.member == null
                ? 'Family member added successfully'
                : 'Family member updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save family member'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: const Text(
          'Are you sure you want to delete this family member? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      final provider = Provider.of<FamilyProvider>(context, listen: false);
      final success = await provider.deleteFamilyMember(widget.member!.id);

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Family member deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.member == null ? 'Add Family Member' : 'Edit Family Member'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Relationship
              DropdownButtonFormField<String>(
                initialValue: _selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship *',
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
                items: FamilyRelationship.all.map((relationship) {
                  return DropdownMenuItem(
                    value: relationship,
                    child: Row(
                      children: [
                        Text(FamilyRelationship.getIcon(relationship)),
                        const SizedBox(width: 8),
                        Text(relationship),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth *',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select date'
                        : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Caregiver Switch
              SwitchListTile(
                title: const Text('Is Caregiver'),
                subtitle: const Text('Can manage medicines and receive alerts'),
                value: _isCaregiver,
                activeThumbColor: const Color(0xFF009688),
                onChanged: (value) {
                  setState(() {
                    _isCaregiver = value;
                    if (!value) {
                      _canReceiveNotifications = false;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              // Notifications Switch
              if (_isCaregiver)
                SwitchListTile(
                  title: const Text('Receive Notifications'),
                  subtitle: const Text('Get alerts about missed medicines'),
                  value: _canReceiveNotifications,
                  activeThumbColor: const Color(0xFF009688),
                  onChanged: (value) {
                    setState(() {
                      _canReceiveNotifications = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.member != null)
          TextButton(
            onPressed: _isLoading ? null : _deleteMember,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveMember,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009688),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.member == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
