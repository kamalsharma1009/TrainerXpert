import 'package:flutter/material.dart';

class WorkoutPlanCard extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String level;

  const WorkoutPlanCard({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.timer, duration),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.speed, level),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // View details
                },
                child: const Text('VIEW PLAN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }
}
