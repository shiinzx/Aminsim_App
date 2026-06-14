import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  
  final List<String> _weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  
  final List<String> _months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  // Approximate Hijri months mapping for reference in 2026
  final Map<int, String> _hijriMonthsFor2026 = {
    1: "Rajab / Sya'ban 1447 H",
    2: "Sya'ban / Ramadhan 1447 H",
    3: "Ramadhan / Syawal 1447 H",
    4: "Syawal / Dzulqa'dah 1447 H",
    5: "Dzulqa'dah / Dzulhijjah 1447 H",
    6: "Dzulhijjah 1447 / Muharram 1448 H",
    7: "Muharram / Shafar 1448 H",
    8: "Shafar / Rabi'ul Awal 1448 H",
    9: "Rabi'ul Awal / Rabi'ul Akhir 1448 H",
    10: "Rabi'ul Akhir / Jumadil Awal 1448 H",
    11: "Jumadil Awal / Jumadil Akhir 1448 H",
    12: "Jumadil Akhir / Rajab 1448 H",
  };

  // Important Islamic Holidays (Gregorian Month/Day mapping)
  final Map<String, String> _holidays = {
    "1-29": "Isra Mi'raj (Approx)",
    "2-18": "Awal Ramadhan (Approx)",
    "3-20": "Hari Raya Idul Fitri 1447 H",
    "3-21": "Hari Raya Idul Fitri 1447 H",
    "5-27": "Hari Raya Idul Adha 1447 H",
    "6-16": "Tahun Baru Islam 1448 H",
    "8-25": "Maulid Nabi Muhammad SAW",
  };

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  List<DateTime> _generateMonthDays(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    
    // Day of the week for the first day (0 = Monday, ..., 6 = Sunday in DateTime, so let's adjust for Sun = 0)
    int firstWeekdayOffset = firstDayOfMonth.weekday % 7;
    
    final List<DateTime> days = [];
    
    // Fill previous month trailing days
    for (int i = firstWeekdayOffset; i > 0; i--) {
      days.add(firstDayOfMonth.subtract(Duration(days: i)));
    }
    
    // Fill current month days
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }
    
    // Fill next month leading days to complete the calendar grid (multiples of 7)
    int totalSlots = days.length;
    int remainingSlots = (7 - (totalSlots % 7)) % 7;
    for (int i = 1; i <= remainingSlots; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final monthDays = _generateMonthDays(_focusedDay);
    final currentHijriMonth = _hijriMonthsFor2026[_focusedDay.month] ?? "Hijri Calendar";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF062743)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kalender Islam",
          style: TextStyle(color: Color(0xFF062743), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          children: [
            // Calendar Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF062743),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                      ),
                      Text(
                        "${_months[_focusedDay.month - 1]} ${_focusedDay.year}",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Text(
                    currentHijriMonth,
                    style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Weekdays row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdays.map((day) {
                return SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF062743), fontSize: 12),
                  ),
                );
              }).toList(),
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
                final isCurrentMonth = day.month == _focusedDay.month;
                final isToday = day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;
                
                final holidayKey = "${day.month}-${day.day}";
                final isHoliday = _holidays.containsKey(holidayKey);

                return Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF062743)
                        : isHoliday
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isHoliday ? Border.all(color: Colors.red, width: 1) : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${day.day}",
                          style: TextStyle(
                            fontWeight: isToday || isHoliday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? Colors.white
                                : isHoliday
                                    ? Colors.red
                                    : isCurrentMonth
                                        ? Colors.black87
                                        : Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 35),

            // Holidays section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Islamic Holidays",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF062743)),
              ),
            ),
            const SizedBox(height: 15),
            ..._holidays.entries.map((entry) {
              final parts = entry.key.split("-");
              final month = int.parse(parts[0]);
              final day = int.parse(parts[1]);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.amber),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF062743)),
                          ),
                          Text(
                            "$day ${_months[month - 1]}",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
