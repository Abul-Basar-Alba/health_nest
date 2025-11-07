// lib/src/screens/pregnancy/doctor_visits_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/doctor_visit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';

class DoctorVisitsScreen extends StatefulWidget {
  const DoctorVisitsScreen({super.key});

  @override
  State<DoctorVisitsScreen> createState() => _DoctorVisitsScreenState();
}

class _DoctorVisitsScreenState extends State<DoctorVisitsScreen> {
  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pregnancyProvider =
        Provider.of<PregnancyProvider>(context, listen: false);

    if (authProvider.user != null &&
        pregnancyProvider.activePregnancy != null) {
      await pregnancyProvider.loadDoctorVisits(
        authProvider.user!.uid,
        pregnancyProvider.activePregnancy!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC), // Cream
      appBar: AppBar(
        title: Consumer<PregnancyProvider>(
          builder: (context, provider, _) => Text(
            provider.isBangla ? 'ডাক্তার পরিদর্শন' : 'Doctor Visits',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFF64B5F6), // Light blue
        elevation: 0,
      ),
      body: Consumer<PregnancyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.doctorVisits.isEmpty) {
            return _buildEmptyState(provider);
          }

          return _buildVisitsList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVisitDialog(context),
        backgroundColor: const Color(0xFF64B5F6),
        icon: const Icon(Icons.add),
        label: Consumer<PregnancyProvider>(
          builder: (context, provider, _) => Text(
            provider.isBangla ? 'পরিদর্শন যোগ করুন' : 'Add Visit',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(PregnancyProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              provider.isBangla
                  ? 'কোনো ডাক্তার পরিদর্শন নেই'
                  : 'No doctor visits scheduled',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.isBangla
                  ? 'আপনার চেকআপ বা আল্ট্রাসাউন্ডের সময় যোগ করুন'
                  : 'Add your checkup or ultrasound appointments',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitsList(PregnancyProvider provider) {
    // Separate upcoming and past visits
    final now = DateTime.now();
    final upcomingVisits = provider.doctorVisits
        .where((v) => v.visitDate.isAfter(now) && !v.isCompleted)
        .toList();
    final pastVisits = provider.doctorVisits
        .where((v) => v.visitDate.isBefore(now) || v.isCompleted)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Upcoming visits
        if (upcomingVisits.isNotEmpty) ...[
          Text(
            provider.isBangla ? 'আসন্ন পরিদর্শন' : 'Upcoming Visits',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...upcomingVisits.map((visit) => _buildVisitCard(visit, provider)),
          const SizedBox(height: 24),
        ],

        // Past visits
        if (pastVisits.isNotEmpty) ...[
          Text(
            provider.isBangla ? 'পূর্ববর্তী পরিদর্শন' : 'Past Visits',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...pastVisits.map((visit) => _buildVisitCard(visit, provider)),
        ],
      ],
    );
  }

  Widget _buildVisitCard(DoctorVisitModel visit, PregnancyProvider provider) {
    final isUpcoming = visit.isUpcoming && !visit.isCompleted;
    final isPastDue = visit.isPastDue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isUpcoming
              ? const Color(0xFF64B5F6)
              : (isPastDue ? Colors.orange : Colors.grey[300]!),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? const Color(0xFF64B5F6).withOpacity(0.2)
                    : (visit.isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                visit.isCompleted
                    ? Icons.check_circle
                    : (visit.visitType == 'ultrasound'
                        ? Icons.monitor_heart
                        : Icons.local_hospital),
                color: visit.isCompleted
                    ? Colors.green
                    : (isUpcoming ? const Color(0xFF64B5F6) : Colors.orange),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.getVisitTypeName(provider.isBangla),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            visit.formattedDate,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            visit.formattedTime,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (visit.doctorName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            visit.doctorName!,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (visit.clinicName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            visit.clinicName!,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Trailing Menu
            if (!visit.isCompleted)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'complete') {
                    provider.completeVisit(visit.id);
                  } else if (value == 'delete') {
                    _confirmDelete(context, visit, provider);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(provider.isBangla ? 'সম্পন্ন' : 'Complete'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(provider.isBangla ? 'মুছুন' : 'Delete'),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
          ],
        ),
      ),
    );
  }

  void _showAddVisitDialog(BuildContext context) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    String selectedType = 'checkup';
    final doctorNameController = TextEditingController();
    final clinicNameController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            provider.isBangla ? 'পরিদর্শন যোগ করুন' : 'Add Visit',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Visit Type
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText:
                        provider.isBangla ? 'পরিদর্শনের ধরন' : 'Visit Type',
                    border: const OutlineInputBorder(),
                  ),
                  items: DoctorVisitModel.visitTypesEN.keys
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              provider.isBangla
                                  ? DoctorVisitModel.visitTypesBN[type]!
                                  : DoctorVisitModel.visitTypesEN[type]!,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    provider.isBangla ? 'তারিখ' : 'Date',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),

                // Time Picker
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    provider.isBangla ? 'সময়' : 'Time',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Doctor Name
                TextField(
                  controller: doctorNameController,
                  decoration: InputDecoration(
                    labelText:
                        provider.isBangla ? 'ডাক্তারের নাম' : 'Doctor Name',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Clinic Name
                TextField(
                  controller: clinicNameController,
                  decoration: InputDecoration(
                    labelText: provider.isBangla
                        ? 'ক্লিনিক/হাসপাতাল'
                        : 'Clinic/Hospital',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: provider.isBangla ? 'নোট' : 'Notes',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 2,
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
                final visitDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final visit = DoctorVisitModel(
                  id: '',
                  userId: authProvider.user!.uid,
                  pregnancyId: provider.activePregnancy!.id,
                  visitDate: visitDate,
                  visitType: selectedType,
                  doctorName: doctorNameController.text.trim().isEmpty
                      ? null
                      : doctorNameController.text.trim(),
                  clinicName: clinicNameController.text.trim().isEmpty
                      ? null
                      : clinicNameController.text.trim(),
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  reminderTime: visitDate.subtract(const Duration(hours: 24)),
                );

                await provider.addDoctorVisit(visit);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64B5F6),
              ),
              child: Text(provider.isBangla ? 'যোগ করুন' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DoctorVisitModel visit,
    PregnancyProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.isBangla ? 'নিশ্চিত করুন' : 'Confirm'),
        content: Text(
          provider.isBangla
              ? 'আপনি কি এই পরিদর্শনটি মুছে ফেলতে চান?'
              : 'Do you want to delete this visit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(provider.isBangla ? 'না' : 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteDoctorVisit(visit.id);
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
