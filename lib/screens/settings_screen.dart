import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _focusMinutes = 25;
  int _totalFocusSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalFocusTime();
  }

  Future<void> _loadTotalFocusTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalFocusSeconds = prefs.getInt('totalFocusSeconds') ?? 0;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Focus Session Length',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _focusMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$_focusMinutes min',
              onChanged: (value) {
                setState(() {
                  _focusMinutes = value.toInt();
                });
              },
            ),
            Text('$_focusMinutes minutes'),
            const SizedBox(height: 30),
            const Text(
              'Total Time Focused',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _formatDuration(_totalFocusSeconds),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _focusMinutes);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
