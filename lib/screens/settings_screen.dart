import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _focusMinutes = 25; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Focus Session Length',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _focusMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11, // steps of 5 minutes
              label: '$_focusMinutes min',
              onChanged: (value) {
                setState(() {
                  _focusMinutes = value.toInt();
                });
              },
            ),
            Text('$_focusMinutes minutes'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _focusMinutes); // return value
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}