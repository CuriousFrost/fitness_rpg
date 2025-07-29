import 'package:flutter/material.dart';
import 'visionary_screen.dart';
import 'workout_screen.dart';
import 'history_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/Visionaries of Sol.png',
            fit: BoxFit.cover,
          ),

          // Menu buttons aligned in the target area
          Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              _buildMenuButton('Log Quest', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutScreen(),
                  ),
                );
              }),
              _buildMenuButton('Visionaries', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisionaryScreen(),
                  ),
                );
              }),
              _buildMenuButton('Quest History', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              }),
              _buildMenuButton('Storybook', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Story mode coming soon!')),
                );
              }),
              _buildMenuButton('Team Builder', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Team Builder coming soon!')),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Kadera',
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
