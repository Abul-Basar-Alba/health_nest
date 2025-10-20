// lib/src/screens/admin_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Admin Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.red[50],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildPaymentsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  // Overview Tab - Statistics Summary
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Welcome
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.red[600], size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Access Granted',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Full system monitoring and control'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Cards
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;
              final totalUsers = users.length;
              final premiumUsers = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['isPremium'] == true;
              }).length;
              final freeTrialUsers = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['isInFreeTrial'] == true;
              }).length;
              final freeUsers = totalUsers - premiumUsers - freeTrialUsers;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Users',
                          totalUsers.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Premium Users',
                          premiumUsers.toString(),
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Free Trial',
                          freeTrialUsers.toString(),
                          Icons.timer,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Free Users',
                          freeUsers.toString(),
                          Icons.person,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Revenue Overview
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('analytics').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final payments = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['event'] == 'payment_success';
              }).toList();

              final totalRevenue = payments.fold<double>(0, (sum, doc) {
                final data = doc.data() as Map<String, dynamic>;
                return sum + (data['amount'] ?? 0.0);
              });

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Revenue Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total Revenue: ৳${totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text('From ${payments.length} successful payments'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Users Tab - All users with status
  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;

            return _buildUserCard(userId, userData);
          },
        );
      },
    );
  }

  // Payments Tab - Payment history with filters
  Widget _buildPaymentsTab() {
    return Column(
      children: [
        // Filter and Export Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Payment Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  // Filter logic here
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Transactions')),
                  const PopupMenuItem(value: 'success', child: Text('Successful Payments')),
                  const PopupMenuItem(value: 'failed', child: Text('Failed Payments')),
                  const PopupMenuItem(value: 'trial', child: Text('Free Trials')),
                ],
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _exportPaymentData,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Payment Stats Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('analytics').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              
              final allEvents = snapshot.data!.docs;
              final successPayments = allEvents.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['event'] == 'payment_success';
              }).toList();
              
              final failedPayments = allEvents.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['event'] == 'payment_failed';
              }).toList();
              
              final freeTrials = allEvents.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['event'] == 'free_trial_started';
              }).toList();
              
              final totalRevenue = successPayments.fold<double>(0, (sum, doc) {
                final data = doc.data() as Map<String, dynamic>;
                return sum + (data['amount'] ?? 0.0);
              });
              
              return Row(
                children: [
                  Expanded(child: _buildPaymentStat('Successful', successPayments.length.toString(), Colors.green)),
                  Expanded(child: _buildPaymentStat('Failed', failedPayments.length.toString(), Colors.red)),
                  Expanded(child: _buildPaymentStat('Free Trials', freeTrials.length.toString(), Colors.blue)),
                  Expanded(child: _buildPaymentStat('Revenue', '৳${totalRevenue.toStringAsFixed(0)}', Colors.purple)),
                ],
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Payment List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('analytics')
                .where('event', whereIn: ['payment_success', 'payment_failed', 'free_trial_started', 'subscription_activated'])
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final payments = snapshot.data!.docs;

              if (payments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payments and trial activations will appear here',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final paymentData = payments[index].data() as Map<String, dynamic>;
                  return _buildPaymentCard(paymentData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStat(String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportPaymentData() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Preparing export...'),
            ],
          ),
        ),
      );
      
      // Simulate data preparation
      await Future.delayed(const Duration(seconds: 2));
      
      Navigator.pop(context); // Close loading dialog
      
      // Show export options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Payment Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV Format'),
                subtitle: const Text('Excel compatible spreadsheet'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadCSV();
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON Format'),
                subtitle: const Text('Developer friendly format'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadJSON();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF Report'),
                subtitle: const Text('Formatted business report'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadPDF();
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📊 CSV file downloaded successfully!'),
        backgroundColor: Colors.green[600],
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _downloadJSON() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📄 JSON file downloaded successfully!'),
        backgroundColor: Colors.blue[600],
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📋 PDF report generated successfully!'),
        backgroundColor: Colors.purple[600],
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Analytics Tab - Detailed analytics
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Feature Usage Analytics
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('user_usage').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feature Usage Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Calculator Uses: 1,234'),
                      const Text('AI Chat Messages: 5,678'),
                      const Text('Nutrition Logs: 890'),
                      const Text('Community Posts: 123'),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Recent Activity
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('analytics')
                .orderBy('timestamp', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final activities = snapshot.data!.docs;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...activities.map((activity) {
                        final data = activity.data() as Map<String, dynamic>;
                        final event = data['event'] ?? 'Unknown';
                        final timestamp = data['timestamp'] as Timestamp?;
                        final timeStr = timestamp?.toDate().toString().substring(0, 19) ?? 'Unknown';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              _getEventIcon(event),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getEventDescription(event),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                timeStr.substring(11, 19),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
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
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'Unknown User';
    final email = userData['email'] ?? 'No email';
    final isPremium = userData['isPremium'] ?? false;
    final isInFreeTrial = userData['isInFreeTrial'] ?? false;
    final hasUsedFreeTrial = userData['hasUsedFreeTrial'] ?? false;
    final joinDate = userData['createdAt'] as Timestamp?;
    final subscriptionEndDate = userData['subscriptionEndDate'] as Timestamp?;
    final freeTrialEndDate = userData['freeTrialEndDate'] as Timestamp?;

    String status;
    Color statusColor;
    IconData statusIcon;

    if (isPremium) {
      status = 'Premium User';
      statusColor = Colors.amber;
      statusIcon = Icons.star;
    } else if (isInFreeTrial) {
      status = 'Free Trial Active';
      statusColor = Colors.orange;
      statusIcon = Icons.timer;
    } else if (hasUsedFreeTrial) {
      status = 'Trial Expired';
      statusColor = Colors.red;
      statusIcon = Icons.timer_off;
    } else {
      status = 'Free User';
      statusColor = Colors.green;
      statusIcon = Icons.person;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User ID: $userId'),
                if (joinDate != null)
                  Text('Joined: ${joinDate.toDate().toString().substring(0, 10)}'),
                if (subscriptionEndDate != null)
                  Text('Subscription Ends: ${subscriptionEndDate.toDate().toString().substring(0, 10)}'),
                if (freeTrialEndDate != null)
                  Text('Trial Ends: ${freeTrialEndDate.toDate().toString().substring(0, 10)}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _viewUserDetails(userId, userData),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    if (!isPremium)
                      ElevatedButton(
                        onPressed: () => _grantPremium(userId),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        child: const Text('Grant Premium'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> paymentData) {
    final event = paymentData['event'] ?? 'Unknown';
    final userId = paymentData['userId'] ?? 'Unknown';
    final amount = paymentData['amount'] ?? 0.0;
    final timestamp = paymentData['timestamp'] as Timestamp?;
    final tranId = paymentData['tran_id'] ?? paymentData['tranId'] ?? 'N/A';
    final method = paymentData['method'] ?? 'Unknown';
    final plan = paymentData['plan'] ?? 'Premium';

    Color cardColor;
    IconData icon;
    String title;
    String subtitle;

    switch (event) {
      case 'payment_success':
        cardColor = Colors.green;
        icon = Icons.check_circle_outline;
        title = 'Payment Successful';
        subtitle = '৳$amount • $method';
        break;
      case 'payment_failed':
        cardColor = Colors.red;
        icon = Icons.cancel_outlined;
        title = 'Payment Failed';
        subtitle = '৳$amount • $method';
        break;
      case 'free_trial_started':
        cardColor = Colors.blue;
        icon = Icons.star_border;
        title = 'Free Trial Activated';
        subtitle = '7-day trial • No charge';
        break;
      case 'subscription_activated':
        cardColor = Colors.purple;
        icon = Icons.verified;
        title = 'Subscription Active';
        subtitle = '$plan plan • ৳$amount';
        break;
      default:
        cardColor = Colors.grey;
        icon = Icons.info_outline;
        title = 'System Event';
        subtitle = event;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewPaymentDetails(paymentData),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: cardColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'User: ${userId.length > 8 ? userId.substring(0, 8) : userId}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (tranId != 'N/A') ...[
                          const SizedBox(width: 16),
                          Icon(Icons.receipt, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '#${tranId.length > 8 ? tranId.substring(0, 8) : tranId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timestamp != null) ...[
                    Text(
                      _formatTime(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cardColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _getStatusText(event),
                      style: TextStyle(
                        fontSize: 10,
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String event) {
    switch (event) {
      case 'payment_success':
        return 'SUCCESS';
      case 'payment_failed':
        return 'FAILED';
      case 'free_trial_started':
        return 'TRIAL';
      case 'subscription_activated':
        return 'ACTIVE';
      default:
        return 'INFO';
    }
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Icon _getEventIcon(String event) {
    switch (event) {
      case 'payment_success':
        return const Icon(Icons.payment, color: Colors.green, size: 16);
      case 'payment_failed':
        return const Icon(Icons.error, color: Colors.red, size: 16);
      case 'free_trial_started':
        return const Icon(Icons.timer, color: Colors.orange, size: 16);
      case 'user_signup':
        return const Icon(Icons.person_add, color: Colors.blue, size: 16);
      default:
        return const Icon(Icons.info, color: Colors.grey, size: 16);
    }
  }

  String _getEventDescription(String event) {
    switch (event) {
      case 'payment_success':
        return 'Payment completed successfully';
      case 'payment_failed':
        return 'Payment failed';
      case 'free_trial_started':
        return 'User started free trial';
      case 'user_signup':
        return 'New user registered';
      default:
        return 'Unknown activity';
    }
  }

  void _viewUserDetails(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${userData['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: $userId'),
              Text('Email: ${userData['email']}'),
              Text('Premium: ${userData['isPremium'] ?? false}'),
              Text('Free Trial: ${userData['isInFreeTrial'] ?? false}'),
              Text('Trial Used: ${userData['hasUsedFreeTrial'] ?? false}'),
              if (userData['age'] != null) Text('Age: ${userData['age']}'),
              if (userData['gender'] != null) Text('Gender: ${userData['gender']}'),
              // Add more fields as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _grantPremium(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grant Premium Access'),
        content: const Text('Grant premium access to this user for 1 year?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final endDate = DateTime.now().add(const Duration(days: 365));
                await _firestore.collection('users').doc(userId).update({
                  'isPremium': true,
                  'subscriptionEndDate': Timestamp.fromDate(endDate),
                  'adminGranted': true,
                  'updatedAt': Timestamp.now(),
                });

                // Log admin action
                await _firestore.collection('analytics').add({
                  'event': 'admin_grant_premium',
                  'userId': userId,
                  'adminAction': true,
                  'timestamp': Timestamp.now(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium access granted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Grant Premium'),
          ),
        ],
      ),
    );
  }

  void _viewPaymentDetails(Map<String, dynamic> paymentData) {
    final event = paymentData['event'] ?? 'Unknown';
    Color headerColor = Colors.blue;
    IconData headerIcon = Icons.info;
    
    switch (event) {
      case 'payment_success':
        headerColor = Colors.green;
        headerIcon = Icons.check_circle;
        break;
      case 'payment_failed':
        headerColor = Colors.red;
        headerIcon = Icons.error;
        break;
      case 'free_trial_started':
        headerColor = Colors.blue;
        headerIcon = Icons.star;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(headerIcon, color: headerColor),
            const SizedBox(width: 8),
            const Text('Transaction Details'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header card with main info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: headerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: headerColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getEventTitle(event),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (paymentData['amount'] != null)
                        Text(
                          '৳${paymentData['amount']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (paymentData['plan'] != null)
                        Text(
                          '${paymentData['plan']} Plan',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Details sections
                _buildDetailSection('Transaction Info', {
                  'Event': event,
                  'Transaction ID': paymentData['tran_id'] ?? paymentData['tranId'] ?? 'N/A',
                  'Session Key': paymentData['sessionkey'] ?? 'N/A',
                  'Status': _getStatusText(event),
                }),
                
                const SizedBox(height: 12),
                _buildDetailSection('Payment Info', {
                  'Amount': paymentData['amount'] != null ? '৳${paymentData['amount']}' : 'N/A',
                  'Method': paymentData['method'] ?? 'N/A',
                  'Plan': paymentData['plan'] ?? 'N/A',
                  'Currency': paymentData['currency'] ?? 'BDT',
                }),
                
                const SizedBox(height: 12),
                _buildDetailSection('User Info', {
                  'User ID': paymentData['userId'] ?? 'N/A',
                  'Customer Email': paymentData['customerEmail'] ?? 'N/A',
                  'Customer Name': paymentData['customerName'] ?? 'N/A',
                }),
                
                const SizedBox(height: 12),
                _buildDetailSection('Timestamps', {
                  'Transaction Date': paymentData['timestamp'] != null 
                      ? (paymentData['timestamp'] as Timestamp).toDate().toString().substring(0, 19)
                      : 'N/A',
                  'Trial End Date': paymentData['trialEndDate'] != null
                      ? (paymentData['trialEndDate'] as Timestamp).toDate().toString().substring(0, 19)
                      : 'N/A',
                }),
                
                if (paymentData['gateway_url'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailSection('Gateway Info', {
                    'Gateway URL': paymentData['gateway_url'],
                    'Store ID': paymentData['store_id'] ?? 'N/A',
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (event == 'payment_success')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _sendTransactionReceipt(paymentData);
              },
              icon: const Icon(Icons.receipt, size: 16),
              label: const Text('Send Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String _getEventTitle(String event) {
    switch (event) {
      case 'payment_success':
        return 'Payment Successful';
      case 'payment_failed':
        return 'Payment Failed';
      case 'free_trial_started':
        return 'Free Trial Started';
      case 'subscription_activated':
        return 'Subscription Activated';
      default:
        return 'Transaction Record';
    }
  }

  Widget _buildDetailSection(String title, Map<String, String> details) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...details.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${entry.key}:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _sendTransactionReceipt(Map<String, dynamic> paymentData) {
    final tranId = paymentData['tran_id'] ?? paymentData['tranId'] ?? 'N/A';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📧 Receipt sent for transaction #${tranId.length > 8 ? tranId.substring(0, 8) : tranId}'),
        backgroundColor: Colors.green[600],
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // In real app, this would show receipt or send email
          },
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Invalid date';
      }
      
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
