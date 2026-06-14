import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  int _subTabIndex = 0; // 0 = Checklist, 1 = Calendar, 2 = Stats
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  List<Map<String, dynamic>> _tasks = [];
  Timer? _countdownTimer;
  String _countdownStr = "00:00:00";
  String _nextSalatName = "Dohr";
  String _nextSalatTime = "13:35";

  // Fixed standard daily Salat times for display/scheduler categories
  final Map<String, String> _salatTimes = {
    "Fajr": "04:42 AM",
    "Dohr": "12:00 PM",
    "Asr": "15:15 PM",
    "Maghrib": "18:02 PM",
    "Isha": "19:15 PM"
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Load tasks from local storage
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('salat_planner_tasks');
      if (tasksJson != null) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(json.decode(tasksJson));
        });
      } else {
        // Load default sample tasks
        final today = DateTime.now();
        setState(() {
          _tasks = [
            {
              "id": "1",
              "title": "Home workout",
              "time": "09:00 AM",
              "salatCategory": "Fajr",
              "isCompleted": true,
              "date": today.toIso8601String()
            },
            {
              "id": "2",
              "title": "Morning Meeting",
              "time": "11:00 AM",
              "salatCategory": "Fajr",
              "isCompleted": true,
              "date": today.toIso8601String()
            },
            {
              "id": "3",
              "title": "Record the podcast",
              "time": "14:00 PM",
              "salatCategory": "Dohr",
              "isCompleted": false,
              "date": today.toIso8601String()
            },
            {
              "id": "4",
              "title": "Go for a mental walk",
              "time": "18:00 PM",
              "salatCategory": "Asr",
              "isCompleted": false,
              "date": today.toIso8601String()
            },
            {
              "id": "5",
              "title": "Read Al-Quran",
              "time": "20:00 PM",
              "salatCategory": "Maghrib",
              "isCompleted": false,
              "date": today.toIso8601String()
            }
          ];
        });
        await _saveTasks();
      }
    } catch (e) {
      // Ignore
    }
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('salat_planner_tasks', json.encode(_tasks));
    } catch (e) {
      // Ignore
    }
  }

  // Countdown timer calculation
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      // Simple daily schedule mappings
      final List<MapEntry<String, DateTime>> salats = [];
      _salatTimes.forEach((key, value) {
        final parts = value.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final int minute = int.parse(timeParts[1]);
        final bool isPm = parts[1] == 'PM';

        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;

        salats.add(MapEntry(key, DateTime(now.year, now.month, now.day, hour, minute)));
      });

      // Find next Salat
      MapEntry<String, DateTime>? next;
      for (final s in salats) {
        if (s.value.isAfter(now)) {
          next = s;
          break;
        }
      }

      if (next == null) {
        // Next salat is tomorrow's Fajr
        final tomorrow = now.add(const Duration(days: 1));
        final fajrTimeParts = _salatTimes['Fajr']!.split(' ')[0].split(':');
        final fHour = int.parse(fajrTimeParts[0]);
        final fMinute = int.parse(fajrTimeParts[1]);
        next = MapEntry('Fajr', DateTime(tomorrow.year, tomorrow.month, tomorrow.day, fHour, fMinute));
      }

      final diff = next.value.difference(now);
      final hrs = diff.inHours.toString().padLeft(2, '0');
      final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');

      if (mounted) {
        setState(() {
          _nextSalatName = next!.key;
          _nextSalatTime = _salatTimes[next.key]!.split(' ')[0];
          _countdownStr = "$hrs:$mins:$secs";
        });
      }
    });
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  List<Map<String, dynamic>> _getTasksForDate(DateTime date) {
    return _tasks.where((t) {
      final tDate = DateTime.tryParse(t['date']);
      return tDate != null && _isSameDay(tDate, date);
    }).toList();
  }

  void _toggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        _tasks[index]['isCompleted'] = !_tasks[index]['isCompleted'];
      }
    });
    _saveTasks();
  }

  void _addTask(String title, String time, String category, DateTime date) {
    setState(() {
      _tasks.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": title,
        "time": time,
        "salatCategory": category,
        "isCompleted": false,
        "date": date.toIso8601String()
      });
    });
    _saveTasks();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t['id'] == id);
    });
    _saveTasks();
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final List<DateTime> dates = [];
    for (int i = 1; i <= 7; i++) {
      dates.add(now.add(Duration(days: i - weekday)));
    }
    return dates;
  }

  List<DateTime> _generateMonthDays(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    int offset = firstDay.weekday % 7;
    final List<DateTime> days = [];

    for (int i = offset; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }
    int slots = days.length;
    int remaining = (7 - (slots % 7)) % 7;
    for (int i = 1; i <= remaining; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: _buildSelectedSubTab(),
      floatingActionButton: _subTabIndex == 0 ? _buildFAB() : null,
      bottomNavigationBar: _buildSubNavBar(),
    );
  }

  Widget _buildSelectedSubTab() {
    switch (_subTabIndex) {
      case 0:
        return _buildChecklistTab();
      case 1:
        return _buildCalendarTab();
      case 2:
        return _buildStatsTab();
      default:
        return _buildChecklistTab();
    }
  }

  // SUB-NAV BAR (Checklist, Calendar, Stats)
  Widget _buildSubNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _subNavItem(Icons.assignment_turned_in, Icons.assignment_turned_in_outlined, 0),
          _subNavItem(Icons.calendar_month, Icons.calendar_today_outlined, 1),
          _subNavItem(Icons.pie_chart, Icons.pie_chart_outline, 2),
        ],
      ),
    );
  }

  Widget _subNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    final isActive = _subTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _subTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
          size: 26,
        ),
      ),
    );
  }

  // TAB 0: DAILY CHECKLIST VIEW
  Widget _buildChecklistTab() {
    final weekDates = _getWeekDates();
    final tasksForSelectedDate = _getTasksForDate(_selectedDate);

    // Group tasks by category
    final Map<String, List<Map<String, dynamic>>> grouped = {
      "Fajr": [],
      "Dohr": [],
      "Asr": [],
      "Maghrib": [],
      "Isha": []
    };
    for (final t in tasksForSelectedDate) {
      final cat = t['salatCategory'] ?? 'Fajr';
      if (grouped.containsKey(cat)) {
        grouped[cat]!.add(t);
      }
    }

    // Determine card background color by index/category
    Color getCardColor(String cat) {
      switch (cat) {
        case "Fajr": return const Color(0xFFEBE9FE); // Pastel Purple
        case "Dohr": return const Color(0xFFFEF3C7); // Pastel Gold
        case "Asr": return const Color(0xFFE0F2FE); // Pastel Blue
        case "Maghrib": return const Color(0xFFFCE8E6); // Pastel Pink
        default: return const Color(0xFFE0F2FE);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    "${_selectedDate.day}/${_selectedDate.month}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              const Icon(Icons.notifications_none, color: Colors.black87, size: 24),
            ],
          ),
          const SizedBox(height: 20),

          // Next Salat Countdown Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Next salat: $_nextSalatName at",
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE9FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _nextSalatTime,
                        style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Text(
                  _countdownStr,
                  style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Weekday selector
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDates.map((date) {
                final isSelected = _isSameDay(date, _selectedDate);
                final dayName = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),

          // Today's Tasks
          const Text(
            "Today's tasks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Text(
            "You're moving forward today.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Task Timeline grouped list
          if (tasksForSelectedDate.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "No tasks scheduled for this day.",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Stack(
              children: [
                // Right-side vertical timeline line
                Positioned(
                  right: 25,
                  top: 15,
                  bottom: 15,
                  child: Container(
                    width: 2,
                    color: const Color(0xFFD1D5DB),
                  ),
                ),

                // Groups Column
                Column(
                  children: grouped.entries.where((entry) => entry.value.isNotEmpty).map((entry) {
                    final String cat = entry.key;
                    final List<Map<String, dynamic>> catTasks = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$cat   ${_salatTimes[cat]}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                              // Circular timeline node point
                              Container(
                                margin: const EdgeInsets.only(right: 20),
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tasks list
                        ...catTasks.map((task) {
                          final isCompleted = task['isCompleted'] ?? false;
                          final cardColor = getCardColor(cat);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12, right: 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task['time'] ?? '',
                                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Complete checkbox button
                                    GestureDetector(
                                      onTap: () => _toggleTask(task['id']),
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: isCompleted ? const Color(0xFF10B981) : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isCompleted ? Colors.transparent : Colors.grey[300]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isCompleted
                                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.black45),
                                      onPressed: () => _deleteTask(task['id']),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // TAB 1: CALENDAR VIEW
  Widget _buildCalendarTab() {
    final monthDays = _generateMonthDays(_focusedMonth);
    final List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];

    final tasksForSelectedDate = _getTasksForDate(_selectedDate);

    Color getCardColor(String cat) {
      switch (cat) {
        case "Fajr": return const Color(0xFFEBE9FE);
        case "Dohr": return const Color(0xFFFEF3C7);
        case "Asr": return const Color(0xFFE0F2FE);
        case "Maghrib": return const Color(0xFFFCE8E6);
        default: return const Color(0xFFE0F2FE);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1)),
                icon: const Icon(Icons.chevron_left, color: Colors.black87),
              ),
              Text(
                "${months[_focusedMonth.month - 1]} ${_focusedMonth.year}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              IconButton(
                onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1)),
                icon: const Icon(Icons.chevron_right, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekdays row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) => SizedBox(
              width: 40,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: monthDays.length,
            itemBuilder: (context, index) {
              final day = monthDays[index];
              final isCurrentMonth = day.month == _focusedMonth.month;
              final isSelected = _isSameDay(day, _selectedDate);
              final hasTasks = _getTasksForDate(day).isNotEmpty;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${day.day}",
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : isCurrentMonth
                                    ? Colors.black87
                                    : Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                        if (hasTasks && !isSelected) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // Scheduled Header
          const Text(
            "Scheduled",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 15),

          // Task lists for selected calendar day
          if (tasksForSelectedDate.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "No tasks scheduled for this day.",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Column(
              children: tasksForSelectedDate.map((task) {
                final cardColor = getCardColor(task['salatCategory'] ?? 'Fajr');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task['time'] ?? '',
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          task['salatCategory'] ?? 'Fajr',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // TAB 2: ANALYTICS / STATS VIEW
  Widget _buildStatsTab() {
    final todayTasks = _getTasksForDate(DateTime.now());
    final total = todayTasks.length;
    final completed = todayTasks.where((t) => t['isCompleted'] == true).length;
    final double completionPercentage = total == 0 ? 0.0 : (completed / total);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Analytics",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 40),

          // Donut progress chart
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    percentage: completionPercentage,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: Colors.grey[200]!,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "${(completionPercentage * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const Text("Today's Tasks", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 50),

          // Stats Breakdown Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("Total Tasks", "$total", const Color(0xFF3B82F6)),
              _buildStatCard("Completed", "$completed", const Color(0xFF10B981)),
              _buildStatCard("Pending", "${total - completed}", const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 30),

          // Helper suggestion
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    total == 0
                        ? "No tasks scheduled for today. Tap the checklist tab to schedule some Salat tasks!"
                        : completionPercentage == 1.0
                            ? "Splendid! All tasks for today are completed. Keep up the great work!"
                            : "You have completed $completed out of $total tasks today. Keep moving forward!",
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Floating Action Button
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddTaskBottomSheet,
      backgroundColor: const Color(0xFF10B981),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // Add Task Sheet Modal
  void _showAddTaskBottomSheet() {
    final TextEditingController titleController = TextEditingController();
    String selectedTime = "09:00 AM";
    String selectedCategory = "Fajr";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add New Task",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),

                  // Title Input
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Task Title (e.g. Home workout)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Salat Slot Category
                  const Text("Associated Salat Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _salatTimes.keys.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setModalState(() {
                          selectedCategory = cat;
                          selectedTime = _salatTimes[cat]!;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF10B981) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Task Time Selector
                  const Text("Scheduled Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (time != null) {
                            final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
                            final hourStr = (time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod).toString().padLeft(2, '0');
                            final minuteStr = time.minute.toString().padLeft(2, '0');
                            setModalState(() {
                              selectedTime = "$hourStr:$minuteStr $period";
                            });
                          }
                        },
                        child: Text(
                          selectedTime,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          _addTask(titleController.text.trim(), selectedTime, selectedCategory, _selectedDate);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Save Task", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Donut Chart Custom Painter
class DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final Color inactiveColor;

  DonutChartPainter({
    required this.percentage,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    
    final paintInactive = Paint()
      ..color = inactiveColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(center, radius, paintInactive);

    final paintActive = Paint()
      ..color = activeColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
