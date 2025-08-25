import 'package:flutter/material.dart';

// Import screens
import 'screens/home_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const FocusPalApp());
}

class FocusPalApp extends StatelessWidget {
  const FocusPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusPal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
      home: const MainPage(), // Start at MainPage with nav bar
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int _focusMinutes = 25;

  void _onItemTapped(int index) async {
    if (index == 3) {
      // Keep Settings tab highlighted
      setState(() => _selectedIndex = 3);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );

      if (result != null && result is int) {
        setState(() => _focusMinutes = result);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Focus time updated to $result minutes')),
        );
      }

      setState(() {
        _selectedIndex = 1;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<Widget> get _screens => [
        const HomeScreen(),
        TimerScreen(focusMinutes: _focusMinutes),
        const RewardsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 3
          ? _screens[1] // while in Settings, just show Timer under it
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
