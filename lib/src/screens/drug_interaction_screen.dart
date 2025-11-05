// lib/src/screens/drug_interaction_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drug_interaction_model.dart';
import '../providers/drug_interaction_provider.dart';
import '../providers/medicine_reminder_provider.dart';

/// Screen to check and display drug interactions for all current medicines
class DrugInteractionScreen extends StatefulWidget {
  const DrugInteractionScreen({super.key});

  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen> {
  @override
  void initState() {
    super.initState();
    _loadInteractions();
  }

  Future<void> _loadInteractions() async {
    final medicineProvider = context.read<MedicineReminderProvider>();
    final interactionProvider = context.read<DrugInteractionProvider>();

    final medicineNames = medicineProvider.medicines
        .where((m) => m.isActive)
        .map((m) => m.medicineName)
        .toList();

    if (medicineNames.isNotEmpty) {
      await interactionProvider.getAllInteractionsForMedicines(medicineNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Interactions'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInteractions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<DrugInteractionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadInteractions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final interactions = provider.currentInteractions;

          if (interactions.isEmpty) {
            return _buildNoInteractionsView();
          }

          return _buildInteractionsList(interactions, provider);
        },
      ),
    );
  }

  Widget _buildNoInteractionsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Drug Interactions Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your current medications don\'t have any known interactions in our database.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Always consult your doctor or pharmacist when adding new medications.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsList(
    List<DrugInteraction> interactions,
    DrugInteractionProvider provider,
  ) {
    final counts = provider.getInteractionsBySeverity();

    return Column(
      children: [
        // Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF009688),
                const Color(0xFF009688).withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.getInteractionSummary(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (counts['major']! > 0)
                    _buildSeverityChip(
                      '${counts['major']} Major',
                      Colors.red,
                    ),
                  if (counts['moderate']! > 0) ...[
                    if (counts['major']! > 0) const SizedBox(width: 8),
                    _buildSeverityChip(
                      '${counts['moderate']} Moderate',
                      Colors.orange,
                    ),
                  ],
                  if (counts['minor']! > 0) ...[
                    if (counts['major']! > 0 || counts['moderate']! > 0)
                      const SizedBox(width: 8),
                    _buildSeverityChip(
                      '${counts['minor']} Minor',
                      Colors.amber,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Interactions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: interactions.length,
            itemBuilder: (context, index) {
              return _buildInteractionCard(interactions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInteractionCard(DrugInteraction interaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: interaction.isMajor
              ? Colors.red.shade300
              : interaction.isModerate
                  ? Colors.orange.shade300
                  : Colors.amber.shade300,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: interaction.isMajor
                        ? Colors.red
                        : interaction.isModerate
                            ? Colors.orange
                            : Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        interaction.isMajor
                            ? Icons.error
                            : interaction.isModerate
                                ? Icons.warning
                                : Icons.info,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        interaction.severity.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Medicine Names
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      interaction.medicine1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      interaction.medicine2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'What happens:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    interaction.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recommendation:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    interaction.recommendation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),

            // Warning for major interactions
            if (interaction.isMajor) ...[
              const SizedBox(height: 12),
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
                        'This is a major interaction. Consult your doctor immediately.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
