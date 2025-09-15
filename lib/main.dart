import 'package:flutter/material.dart';
import 'package:focuspal/widgets/background.dart';
import 'screens/timer_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/pet_screen.dart';
import 'package:focuspal/models/player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FocusPalApp());
}

class FocusPalApp extends StatelessWidget {
  const FocusPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusPal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainPage(),
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
  Player? player;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayer();
    });
  }

  Future<void> _loadPlayer() async {
    try {
      player = await Player.load();
      setState(() {});
    } catch (e, stack) {
      debugPrint("_loadPlayer() failed: $e\n$stack");
      setState(() {
        player = Player();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (result != null && result is int) {
      setState(() => _focusMinutes = result);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Focus time updated to $result minutes'),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  List<Widget> get _screens {
    if (player == null) return [];
    return [
      ScreenWrapper(
        title: 'Timer',
        onSettingsPressed: _openSettings,
        child: TimerScreen(focusMinutes: _focusMinutes, player: player!),
      ),
      ScreenWrapper(
        title: 'Rewards',
        onSettingsPressed: _openSettings,
        child: RewardsScreen(player: player!),
      ),
      ScreenWrapper(
        title: 'Shop',
        onSettingsPressed: _openSettings,
        child: RewardsShop(player: player!),
      ),
      ScreenWrapper(
        title: 'Collection',
        onSettingsPressed: _openSettings,
        child: CollectionScreen(player: player!),
      ),
      ScreenWrapper(
        title: 'Pets',
        onSettingsPressed: _openSettings,
        child: PetScreen(player: player!),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (player == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shelves), label: 'Collection'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
        ],
      ),
    );
  }
}

class ScreenWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSettingsPressed;

  const ScreenWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
      body: BackgroundWrapper(child: child),
    );
  }
}
