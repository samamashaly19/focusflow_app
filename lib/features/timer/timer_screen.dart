// lib/features/timer/timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  static const int studyMinutes = 25;
  static const int breakMinutes = 5;

  int remainingSeconds = studyMinutes * 60;
  bool isRunning = false;
  bool isStudy = true;
  int sessionsCompleted = 0;
  Timer? _timer;

  // الحل: لازم نعمل initialize هنا
  late final AnimationController _progressController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // تهيئة الـ Controllers
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: remainingSeconds),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (isRunning) return;
    setState(() => isRunning = true);

    // إعادة ضبط الـ duration والـ animation
    final totalSeconds = isStudy ? studyMinutes * 60 : breakMinutes * 60;
    _progressController.duration = Duration(seconds: totalSeconds);
    final progress = 1.0 - (remainingSeconds / totalSeconds);
    _progressController.value = progress;
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _completeSession();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _progressController.stop();
    setState(() => isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    _progressController.reset();
    setState(() {
      isRunning = false;
      isStudy = true;
      remainingSeconds = studyMinutes * 60;
      sessionsCompleted = 0;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _progressController.reset();
    setState(() {
      isRunning = false;
      if (isStudy) sessionsCompleted++;
      isStudy = !isStudy;
      remainingSeconds = (isStudy ? studyMinutes : breakMinutes) * 60;
    });

    // تحديث الـ animation duration للجلسة الجديدة
    final totalSeconds = isStudy ? studyMinutes * 60 : breakMinutes * 60;
    _progressController.duration = Duration(seconds: totalSeconds);
  }

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // تم تصليح السطر ده
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : isStudy
                ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                : [Colors.teal.shade600, Colors.teal.shade400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                isStudy ? 'Focus Time' : 'Break Time',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sessions Completed: $sessionsCompleted',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 60),

              // الدائرة + التايمر
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value:
                              1.0 -
                              (remainingSeconds /
                                  (isStudy
                                      ? studyMinutes * 60
                                      : breakMinutes * 60)),
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isRunning
                                ? 1.0 + (_pulseController.value * 0.1)
                                : 1.0,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  isRunning ? 0.15 : 0.1,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 80),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: isRunning ? 'Pause' : 'Start',
                    onTap: isRunning ? _stopTimer : _startTimer,
                    color: Colors.white,
                    textColor: const Color(0xFF667eea),
                  ),
                  const SizedBox(width: 24),
                  _ControlButton(
                    icon: Icons.refresh_rounded,
                    label: 'Reset',
                    onTap: _resetTimer,
                    color: Colors.white.withOpacity(0.2),
                    textColor: Colors.white,
                  ),
                ],
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isStudy
                      ? '"Stay focused and never give up."'
                      : '"Rest and come back stronger."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
