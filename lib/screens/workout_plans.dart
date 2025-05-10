import 'package:flutter/material.dart';
import 'package:trainerxpert/widgets/workout_plan_card.dart';

class WorkoutPlansScreen extends StatelessWidget {
  const WorkoutPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plans')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          WorkoutPlanCard(
            title: 'Beginner Full Body',
            description: '4-week plan for beginners',
            duration: '30-45 mins',
            level: 'Beginner',
          ),
          WorkoutPlanCard(
            title: 'Intermediate Strength',
            description: 'Build muscle and strength',
            duration: '45-60 mins',
            level: 'Intermediate',
          ),
          WorkoutPlanCard(
            title: 'Advanced HIIT',
            description: 'High intensity interval training',
            duration: '20-30 mins',
            level: 'Advanced',
          ),
          WorkoutPlanCard(
            title: 'Weight Loss Program',
            description: 'Burn fat effectively',
            duration: '30-45 mins',
            level: 'All Levels',
          ),
        ],
      ),
    );
  }
}
