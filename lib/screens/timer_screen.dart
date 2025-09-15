import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focuspal/models/player.dart';
import 'package:focuspal/widgets/timer_background.dart';

class TimerScreen extends StatefulWidget {
  final int focusMinutes;
  final Player player;

  const TimerScreen({
    super.key,
    required this.focusMinutes,
    required this.player,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
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
    WidgetsBinding.instance.addObserver(this);
    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadTimerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _levelUpController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseTimer();
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      _loadTimerState();
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remainingSeconds', _remainingSeconds);
    await prefs.setBool('isRunning', _isRunning);
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSeconds = prefs.getInt('remainingSeconds');
    setState(() {
      _remainingSeconds = savedSeconds ?? widget.focusMinutes * 60;
      _isRunning = false;
    });
  }

  Future<void> _updateTotalFocusTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('totalFocusSeconds') ?? 0;
    await prefs.setInt('totalFocusSeconds', current + seconds);
  }

  void _startTimer() {
    if (_isRunning || _remainingSeconds <= 0) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _elapsedSeconds++;
        });

        _updateTotalFocusTime(1); // <-- Track time

        if (_elapsedSeconds % 60 == 0) {
          (() async {
            final newRewards = await widget.player.addXp(1);
            setState(() => widget.player.coins += 1);
            await widget.player.save();
            if (newRewards.isNotEmpty) {
              _levelUpController.forward(from: 0.0);
              for (var reward in newRewards) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text("🎉 Level ${widget.player.level}! Reward: $reward"),
                            duration: Duration(seconds: 1)),
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
      _saveTimerState();
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _saveTimerState();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.focusMinutes * 60;
      _isRunning = false;
      _elapsedSeconds = 0;
    });
    _saveTimerState();
  }

  void _showCompletionDialog() async {
    final xpGained = widget.focusMinutes;
    final newRewards = await widget.player.addXp(xpGained);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Session Complete 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You gained $xpGained XP and $xpGained Coins!"),
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
    final totalSeconds = widget.focusMinutes * 60;
    final progress = 1 - (_remainingSeconds / totalSeconds);

   return BackgroundWrapper(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Circular Timer
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  _formatTime(_remainingSeconds),
                 style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
               ),
             ],
           ),
           const SizedBox(height: 20),

           // XP Progress Bar
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
              "Lvl: ${widget.player.level} | XP: ${widget.player.xp}/${widget.player.getXpForNextLevel()} | Coins: ${widget.player.coins}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final newRewards = await widget.player.addXp(10);
                    setState(() {
                      widget.player.coins += 10;
                    });
                    await widget.player.save();
                    if (newRewards.isNotEmpty) {
                      for (var reward in newRewards) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text("Unlocked: $reward"), duration: Duration(seconds: 1)),
                          );
                      }
                    } else {
                         ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text("Added 10 XP & 10 Coins!"), duration: Duration(seconds: 1)),
                        );
                     }
                   },
                  child: const Text("DEBUG: Add XP & Coins"),
                   ),
              ],
            ),
          ],
        ),
      ),
       );
   }
  }
