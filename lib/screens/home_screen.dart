import 'package:flutter/material.dart';
import 'package:trainerxpert/screens/chat_screen.dart';
import 'package:trainerxpert/screens/workout_plans.dart';
import 'package:trainerxpert/screens/nutrition_guide.dart';
import 'package:trainerxpert/screens/progress_tracker.dart';
import 'package:trainerxpert/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrainerXpert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to TrainerXpert',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your AI-powered fitness companion',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  FeatureCard(
                    icon: Icons.chat,
                    title: 'AI Trainer Chat',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.fitness_center,
                    title: 'Workout Plans',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkoutPlansScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.restaurant,
                    title: 'Nutrition Guide',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NutritionGuideScreen(),
                        ),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.trending_up,
                    title: 'Progress Tracker',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProgressTrackerScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
