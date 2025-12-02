import 'package:flutter/material.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/tasks_screen.dart';
import '../timer/timer_screen.dart';
import '../../data/db/tasks_database.dart';
import '../../data/models/task_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleDarkMode;
  final String userName;

  const HomeScreen({super.key, this.onToggleDarkMode, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TaskModel>> _todayTasksFuture;

  final List<String> quotes = [
    "Small steps every day.",
    "Focus on what matters.",
    "Stay positive, work hard.",
    "Consistency beats intensity.",
    "Believe you can and you're halfway there.",
  ];

  String getTodayQuote() {
    final day = DateTime.now().day;
    return quotes[day % quotes.length];
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  void _loadTodayTasks() {
    setState(() {
      _todayTasksFuture = TasksDatabase.instance.readAllTasks().then((tasks) {
        final today = DateTime.now();
        final todayStr =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        return tasks.where((t) => t.date == todayStr).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Focus-Flow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleDarkMode ?? () {},
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + Quote Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getGreeting()},',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        getTodayQuote(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _stylishButton(
                        icon: Icons.checklist_rounded,
                        label: 'My Tasks',
                        color: Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TasksScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _stylishButton(
                        icon: Icons.timer,
                        label: 'Focus Mode',
                        color: Colors.orange.shade600,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TimerScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Today's Tasks Title
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Tasks List
                Expanded(
                  child: FutureBuilder<List<TaskModel>>(
                    future: _todayTasksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final tasks = snapshot.data ?? [];

                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sentiment_satisfied_alt,
                                size: 70,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No tasks today!\nTake a well-deserved break",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: Colors.white.withOpacity(0.12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                leading: Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: task.isCompleted == 1,
                                    activeColor: Colors.green,
                                    shape: const CircleBorder(),
                                    side: const BorderSide(
                                      color: Colors.white70,
                                    ),
                                    onChanged: (_) async {
                                      task.isCompleted = task.isCompleted == 0
                                          ? 1
                                          : 0;
                                      try {
                                        await TasksDatabase.instance.updateTask(
                                          task,
                                        );
                                        _loadTodayTasks();
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update task: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted == 1
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${task.date} • ${task.time}',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddTaskScreen(task: task),
                                          ),
                                        );
                                        if (result == true) _loadTodayTasks();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        if (task.id != null) {
                                          try {
                                            await TasksDatabase.instance
                                                .deleteTask(task.id!);
                                            _loadTodayTasks();
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to delete task: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stylishButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 10,
        shadowColor: color.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
