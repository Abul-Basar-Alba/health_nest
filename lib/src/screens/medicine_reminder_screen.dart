// lib/src/screens/medicine_reminder_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/drug_interaction_model.dart';
import '../models/medicine_model.dart';
import '../providers/drug_interaction_provider.dart';
import '../providers/medicine_reminder_provider.dart';
import 'drug_interaction_screen.dart';
import 'medicine_statistics_screen.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<MedicineReminderProvider>().listenToMedicines(userId);
        context.read<MedicineReminderProvider>().loadAdherence(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Medicine Reminder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrugInteractionScreen(),
                ),
              );
            },
            tooltip: 'Check Drug Interactions',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicineStatisticsScreen(),
                ),
              );
            },
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: Consumer<MedicineReminderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdherenceCard(provider),
                _buildTodaysSchedule(provider),
                _buildAllMedicines(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context),
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }

  Widget _buildAdherenceCard(MedicineReminderProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adherence Rate',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.adherenceRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSchedule(MedicineReminderProvider provider) {
    if (provider.todaysSchedule.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No medicines scheduled for today',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.todaysSchedule.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final schedule = provider.todaysSchedule[index];
              final medicine = schedule['medicine'] as MedicineModel;
              final scheduledTime = schedule['scheduledTime'] as DateTime;
              final status = schedule['status'] as String;

              return _buildScheduleItem(medicine, scheduledTime, status);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
      MedicineModel medicine, DateTime scheduledTime, String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'taken':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'missed':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF009688).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.medication,
          color: Color(0xFF009688),
          size: 28,
        ),
      ),
      title: Text(
        medicine.medicineName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
              '${medicine.dosage} • ${DateFormat('h:mm a').format(scheduledTime)}'),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: status == 'pending'
          ? IconButton(
              icon: const Icon(Icons.check_circle_outline),
              color: const Color(0xFF009688),
              onPressed: () {
                if (userId != null) {
                  context.read<MedicineReminderProvider>().markAsTaken(
                        medicine.id,
                        userId,
                        scheduledTime,
                      );
                }
              },
            )
          : null,
    );
  }

  Widget _buildAllMedicines(MedicineReminderProvider provider) {
    if (provider.medicines.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No medicines added yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'All Medicines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.medicines.length,
          itemBuilder: (context, index) {
            final medicine = provider.medicines[index];
            return _buildMedicineCard(medicine);
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditMedicineDialog(context, medicine),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009688).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Color(0xFF009688),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.medicineName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medicine.dosage} • ${medicine.medicineType}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (medicine.isStockLow())
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Low Stock',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (medicine.needsRenewal())
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_late,
                              size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Renew Soon',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (medicine.isPrescriptionExpired())
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Expired',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                      Icons.schedule,
                      medicine.frequency == 'interval' &&
                              medicine.intervalHours != null
                          ? 'Every ${medicine.intervalHours}h'
                          : medicine.frequency),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                      Icons.inventory_2, 'Stock: ${medicine.stockCount}'),
                ],
              ),
              if (medicine.instructions != null &&
                  medicine.instructions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  medicine.instructions!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditMedicineDialog(),
    );
  }

  void _showEditMedicineDialog(BuildContext context, MedicineModel medicine) {
    showDialog(
      context: context,
      builder: (context) => AddEditMedicineDialog(medicine: medicine),
    );
  }
}

class AddEditMedicineDialog extends StatefulWidget {
  final MedicineModel? medicine;

  const AddEditMedicineDialog({super.key, this.medicine});

  @override
  State<AddEditMedicineDialog> createState() => _AddEditMedicineDialogState();
}

class _AddEditMedicineDialogState extends State<AddEditMedicineDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _stockController;
  late TextEditingController _instructionsController;
  late TextEditingController _intervalHoursController;
  late TextEditingController _renewalReminderDaysController;

  String _frequency = 'daily';
  String _medicineType = 'Tablet';
  List<TimeOfDay> _scheduledTimes = [];
  List<String> _weekDays = [];
  int _refillThreshold = 5;
  DateTime? _prescriptionExpiryDate;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.medicine?.medicineName ?? '');
    _dosageController =
        TextEditingController(text: widget.medicine?.dosage ?? '');
    _stockController = TextEditingController(
        text: widget.medicine?.stockCount.toString() ?? '30');
    _instructionsController =
        TextEditingController(text: widget.medicine?.instructions ?? '');
    _intervalHoursController = TextEditingController(
        text: widget.medicine?.intervalHours?.toString() ?? '6');
    _renewalReminderDaysController = TextEditingController(
        text: widget.medicine?.renewalReminderDays?.toString() ?? '7');

    if (widget.medicine != null) {
      _frequency = widget.medicine!.frequency;
      _medicineType = widget.medicine!.medicineType ?? 'Tablet';
      _scheduledTimes = widget.medicine!.scheduledTimes.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
      _weekDays =
          widget.medicine!.weekDays?.map((day) => day.toString()).toList() ??
              [];
      _refillThreshold = widget.medicine!.refillThreshold ?? 5;
      _prescriptionExpiryDate = widget.medicine!.prescriptionExpiryDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicine == null ? 'Add Medicine' : 'Edit Medicine',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medication),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _medicineType,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    'Tablet',
                    'Capsule',
                    'Syrup',
                    'Injection',
                    'Drops',
                    'Inhaler',
                    'Other'
                  ]
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _medicineType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 500mg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_size),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter dosage';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: ['daily', 'weekly', 'custom', 'interval']
                      .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq == 'interval'
                              ? 'EVERY X HOURS'
                              : freq.toUpperCase())))
                      .toList(),
                  onChanged: (value) => setState(() => _frequency = value!),
                ),
                if (_frequency == 'interval') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _intervalHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Interval (Hours)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                      helperText: 'e.g., 6 for every 6 hours',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_frequency == 'interval' &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter interval hours';
                      }
                      final hours = int.tryParse(value ?? '');
                      if (hours == null || hours <= 0 || hours > 24) {
                        return 'Enter valid hours (1-24)';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Scheduled Times',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                if (_frequency == 'interval')
                  const Text(
                    '  (First dose time)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._scheduledTimes.map((time) => Chip(
                          label: Text(time.format(context)),
                          onDeleted: () =>
                              setState(() => _scheduledTimes.remove(time)),
                        )),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add Time'),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _scheduledTimes.add(time));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Count',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _refillThreshold.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Refill Alert',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _refillThreshold = int.tryParse(value) ?? 5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Prescription Expiry Section
                Card(
                  elevation: 0,
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment,
                                size: 20, color: Colors.teal),
                            SizedBox(width: 8),
                            Text(
                              'Prescription Tracking',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _prescriptionExpiryDate ??
                                        DateTime.now()
                                            .add(const Duration(days: 30)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(
                                        () => _prescriptionExpiryDate = date);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Expiry Date',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _prescriptionExpiryDate != null
                                        ? '${_prescriptionExpiryDate!.day}/${_prescriptionExpiryDate!.month}/${_prescriptionExpiryDate!.year}'
                                        : 'Not set',
                                    style: TextStyle(
                                      color: _prescriptionExpiryDate != null
                                          ? Colors.black87
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _renewalReminderDaysController,
                                decoration: const InputDecoration(
                                  labelText: 'Remind (Days)',
                                  border: OutlineInputBorder(),
                                  helperText: 'Days before expiry',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        if (_prescriptionExpiryDate != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _prescriptionExpiryDate = null);
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.medicine != null)
                      TextButton(
                        onPressed: () {
                          context
                              .read<MedicineReminderProvider>()
                              .deleteMedicine(widget.medicine!.id);
                          Navigator.pop(context);
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveMedicine() async {
    if (_formKey.currentState!.validate() && _scheduledTimes.isNotEmpty) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final scheduledTimeStrings = _scheduledTimes.map((time) {
        final hour = time.hour.toString().padLeft(2, '0');
        final minute = time.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }).toList();

      final weekDayInts = _weekDays.map((day) => int.parse(day)).toList();

      final medicine = MedicineModel(
        id: widget.medicine?.id ?? '',
        userId: userId,
        medicineName: _nameController.text,
        dosage: _dosageController.text,
        frequency: _frequency,
        scheduledTimes: scheduledTimeStrings,
        weekDays: weekDayInts.isNotEmpty ? weekDayInts : null,
        intervalHours: _frequency == 'interval'
            ? int.tryParse(_intervalHoursController.text)
            : null,
        startDate: widget.medicine?.startDate ?? DateTime.now(),
        endDate: widget.medicine?.endDate,
        stockCount: int.tryParse(_stockController.text) ?? 30,
        refillThreshold: _refillThreshold,
        instructions: _instructionsController.text,
        medicineType: _medicineType,
        isActive: widget.medicine?.isActive ?? true,
        createdAt: widget.medicine?.createdAt ?? DateTime.now(),
        prescriptionExpiryDate: _prescriptionExpiryDate,
        renewalReminderDays: _prescriptionExpiryDate != null
            ? int.tryParse(_renewalReminderDaysController.text) ?? 7
            : null,
      );

      // Check for drug interactions before adding
      if (widget.medicine == null) {
        // Adding new medicine - check interactions
        final provider = context.read<MedicineReminderProvider>();
        final existingMedicines =
            provider.medicines.map((m) => m.medicineName).toList();

        if (existingMedicines.isNotEmpty) {
          final interactionProvider = context.read<DrugInteractionProvider>();
          final interactions =
              await interactionProvider.checkInteractionsForNewMedicine(
            medicine.medicineName,
            existingMedicines,
          );

          if (interactions.isNotEmpty && mounted) {
            // Show warning dialog
            final proceed = await _showInteractionWarningDialog(
              context,
              interactions,
            );

            if (!proceed) {
              return; // User cancelled
            }
          }
        }

        if (mounted) {
          context.read<MedicineReminderProvider>().addMedicine(medicine);
          Navigator.pop(context);
        }
      } else {
        // Updating existing medicine
        context.read<MedicineReminderProvider>().updateMedicine(medicine);
        Navigator.pop(context);
      }
    } else if (_scheduledTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one scheduled time')),
      );
    }
  }

  Future<bool> _showInteractionWarningDialog(
    BuildContext context,
    List<DrugInteraction> interactions,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: interactions.any((i) => i.isMajor)
                      ? Colors.red
                      : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Drug Interaction Warning',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found ${interactions.length} potential interaction${interactions.length > 1 ? 's' : ''}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...interactions.map((interaction) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: interaction.isMajor
                              ? Colors.red.shade50
                              : interaction.isModerate
                                  ? Colors.orange.shade50
                                  : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: interaction.isMajor
                                ? Colors.red.shade300
                                : interaction.isModerate
                                    ? Colors.orange.shade300
                                    : Colors.amber.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: interaction.isMajor
                                        ? Colors.red
                                        : interaction.isModerate
                                            ? Colors.orange
                                            : Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    interaction.severity.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${interaction.medicine1} + ${interaction.medicine2}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              interaction.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      interaction.recommendation,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  if (interactions.any((i) => i.isMajor))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Major interactions can be dangerous. Please consult your doctor before proceeding.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: interactions.any((i) => i.isMajor)
                      ? Colors.red
                      : Colors.orange,
                ),
                child: const Text(
                  'Proceed Anyway',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    _instructionsController.dispose();
    _intervalHoursController.dispose();
    _renewalReminderDaysController.dispose();
    super.dispose();
  }
}
