import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focuspal/models/player.dart';

class TimerScreen extends StatefulWidget {
  final int focusMinutes;
  final Player player;

  TimerScreen({super.key, required this.focusMinutes, required this.player});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  int _elapsedSeconds = 0;

  late AnimationController _levelUpController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _resetTimer();

    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _levelUpController.dispose();
    super.dispose();
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = widget.focusMinutes * 60;
      _isRunning = false;
      _elapsedSeconds = 0;
    });
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _elapsedSeconds++;
        });
          // 1 XP per minute
          if (_elapsedSeconds % 60 == 0) {
            (() async{
            final newRewards = await widget.player.addXp(1);
            if (newRewards.isNotEmpty) {
              await widget.player.save();
              _levelUpController.forward(from: 0.0);
              for (var reward in newRewards) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Level ${widget.player.level}! Reward unlocked: $reward")),
                );
              }
            }
          })();
        }
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
        _showCompletionDialog();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _showCompletionDialog() async{
    final xpGained = widget.focusMinutes;
    final newRewards = await widget.player.addXp(xpGained);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Session Complete 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Well done! You've gained $xpGained XP."),
            ...newRewards.map((r) => Text("Unlocked: $r")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FocusPal - Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // XP Bar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 250,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.player.getXpProgress(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _levelUpController,
                  child: const Text(
                    "Level Up!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Level: ${widget.player.level}  |  XP: ${widget.player.xp}/${widget.player.getXpForNextLevel()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text("Start"),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : null,
                  child: const Text("Pause"),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}