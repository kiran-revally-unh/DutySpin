import 'package:flutter/material.dart';

import '../theme.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'roommates_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const RoommatesScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primaryMuted,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Roommates'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
