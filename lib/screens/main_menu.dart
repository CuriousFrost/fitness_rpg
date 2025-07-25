import 'package:flutter/material.dart';
import 'visionary_screen.dart';
import 'workout_screen.dart';
import 'history_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'FITNESS RPG',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuButton(
                      icon: Icons.fitness_center,
                      label: 'Log Workout',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      icon: Icons.person,
                      label: 'Visionaries',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CharacterScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      icon: Icons.history,
                      label: 'Workout History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      icon: Icons.menu_book,
                      label: 'Storybook',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Story mode coming soon!')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      icon: Icons.group,
                      label: 'Team Builder',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Team Builder coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.white24,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
