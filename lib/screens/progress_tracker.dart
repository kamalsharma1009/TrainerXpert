import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  _ProgressTrackerScreenState createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  final List<Map<String, dynamic>> _progressEntries = [
    {
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'weight': 75.5,
      'bodyFat': 18.0,
      'notes': 'Feeling good after first week',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'weight': 74.8,
      'bodyFat': 17.5,
      'notes': 'Increased protein intake',
    },
    {
      'date': DateTime.now(),
      'weight': 74.2,
      'bodyFat': 17.0,
      'notes': 'Best workout this week',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addNewEntry),
        ],
      ),
      body:
          _progressEntries.isEmpty
              ? const Center(
                child: Text('No progress entries yet. Add your first entry!'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _progressEntries.length,
                itemBuilder: (context, index) {
                  final entry = _progressEntries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM d, y').format(entry['date']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMetric('Weight', '${entry['weight']} kg'),
                              const SizedBox(width: 16),
                              _buildMetric('Body Fat', '${entry['bodyFat']}%'),
                            ],
                          ),
                          if (entry['notes'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              entry['notes'],
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _addNewEntry() {
    // Implementation for adding new entry
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Progress Entry'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Body Fat (%)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Save logic
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
