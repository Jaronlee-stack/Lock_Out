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

  void _onItemTapped(int index) async {
    if (index == 5) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );

      if (result != null && result is int) {
        setState(() => _focusMinutes = result);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
          SnackBar(content: Text('Focus time updated to $result minutes'),
                  duration: Duration(seconds: 1)),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<Widget> get _screens {
    if (player == null) return [];
    return [
      TimerScreen(focusMinutes: _focusMinutes, player: player!),
      RewardsScreen(player: player!),
      RewardsShop(player: player!),
      CollectionScreen(player: player!,),
      PetScreen(player: player!,)
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
      body: BackgroundWrapper(
      child: _screens[_selectedIndex],
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}