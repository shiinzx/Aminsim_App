import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'asmaul_husna_page.dart';
import 'doa_page.dart';
import 'hadith_page.dart';
import 'sholat_page.dart';
import 'kiblat_page.dart';
import 'tasbih_page.dart';
import 'calendar_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onQuranTap;
  const MenuPage({super.key, this.onQuranTap});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isExpanded = false;
  Timer? _timer;
  String _timeString = "-- : --";
  String _countdownString = "--:--:--";
  String _nextPrayerName = "";
  String _dateString = "";
  String _cityString = "Cianjur, Indonesia";
  final String _cityId = "1205"; // Default city ID for Cianjur in myquran API
  Map<String, dynamic> todaySchedule = {};
  bool isLoadingPrayer = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeAndCountdown();
    });
    // Run once initially to avoid blank values before first tick
    _updateTimeAndCountdown();
  }

  Future<void> _fetchTodayPrayerTimes() async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    try {
      final response = await http.get(Uri.parse('https://api.myquran.com/v2/sholat/jadwal/$_cityId/$year/$month/$day'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          if (mounted) {
            setState(() {
              todaySchedule = responseData['data']['jadwal'] ?? {};
              _cityString = "${responseData['data']['lokasi'] ?? 'CIANJUR'}, Indonesia";
              isLoadingPrayer = false;
            });
            _updateTimeAndCountdown();
          }
        }
      }
    } catch (e) {
      // Offline fallback
      if (mounted) {
        setState(() {
          todaySchedule = _staticBackupSchedule;
          _cityString = "Cianjur, Indonesia";
          isLoadingPrayer = false;
        });
        _updateTimeAndCountdown();
      }
    }
  }

  void _updateTimeAndCountdown() {
    final now = DateTime.now();
    
    // Clock update
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    // Pulsing colon
    final colon = now.second % 2 == 0 ? " : " : "   ";
    final timeStr = "$hour$colon$minute";

    // Date update
    final dateStr = _getFormattedDate(now);

    // Countdown calculation
    String nextName = "";
    String countStr = "--:--:--";

    if (todaySchedule.isNotEmpty) {
      final List<MapEntry<String, DateTime>> prayerTimes = [];
      final subuhTime = _parseTime(todaySchedule['subuh'], now);
      final dzuhurTime = _parseTime(todaySchedule['dzuhur'], now);
      final asharTime = _parseTime(todaySchedule['ashar'], now);
      final magribTime = _parseTime(todaySchedule['magrib'], now);
      final isyaTime = _parseTime(todaySchedule['isya'], now);

      if (subuhTime != null) prayerTimes.add(MapEntry('Subuh', subuhTime));
      if (dzuhurTime != null) prayerTimes.add(MapEntry('Dzuhur', dzuhurTime));
      if (asharTime != null) prayerTimes.add(MapEntry('Ashar', asharTime));
      if (magribTime != null) prayerTimes.add(MapEntry('Magrib', magribTime));
      if (isyaTime != null) prayerTimes.add(MapEntry('Isya', isyaTime));

      MapEntry<String, DateTime>? nextPrayer;
      for (final prayer in prayerTimes) {
        if (prayer.value.isAfter(now)) {
          nextPrayer = prayer;
          break;
        }
      }

      // If past Isya, next is tomorrow's Subuh
      if (nextPrayer == null && subuhTime != null) {
        final tomorrowSubuh = subuhTime.add(const Duration(days: 1));
        nextPrayer = MapEntry('Subuh', tomorrowSubuh);
      }

      if (nextPrayer != null) {
        nextName = nextPrayer.key;
        final diff = nextPrayer.value.difference(now);
        final diffHours = diff.inHours.toString().padLeft(2, '0');
        final diffMinutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final diffSeconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        countStr = "$diffHours:$diffMinutes:$diffSeconds";
      }
    }

    if (mounted) {
      setState(() {
        _timeString = timeStr;
        _dateString = dateStr;
        _nextPrayerName = nextName;
        _countdownString = countStr;
      });
    }
  }

  DateTime? _parseTime(String? timeStr, DateTime date) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _getFormattedDate(DateTime date) {
    final days = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"];
    final months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    // weekday is 1 = Monday, 7 = Sunday. Sunday offset is 0.
    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];
    return "$dayName, ${date.day} $monthName ${date.year}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpandableMenu(),
                const SizedBox(height: 30),
                const Text(
                  "Jadwal Sholat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF062743),
                  ),
                ),
                const SizedBox(height: 15),
                _buildPrayerTimesRow(),
                const SizedBox(height: 30),
                const Text(
                  "Prayer Tracker",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF062743),
                  ),
                ),
                const SizedBox(height: 15),
                
                // --- BAGIAN SLIDE TRACKER ---
                SizedBox(
                  height: 160,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.95),
                    children: [
                      _buildTrackerSlide("Today"),
                      _buildTrackerSlide("Yesterday"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk Kartu Tracker yang bisa di-slide
  Widget _buildTrackerSlide(String day) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PRAYER TRACKER - $day", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _trackerMiniItem(true), // Subuh
              _trackerMiniItem(true), // Dzuhur
              _trackerMiniItem(true), // Ashar
              _trackerMiniItem(false), // Magrib
              _trackerMiniItem(false), // Isya
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: day == "Today" ? Colors.black : Colors.grey, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: day == "Yesterday" ? Colors.black : Colors.grey, shape: BoxShape.circle)),
            ],
          )
        ],
      ),
    );
  }

  Widget _trackerMiniItem(bool isDone) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFBCCBCF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.check_circle,
        color: isDone ? const Color(0xFF062743) : Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/masjid_header.jpg',
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          Center(
            child: Text(
              _timeString,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 15.0,
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF062743),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("REMAIN TIME", style: TextStyle(color: Colors.white60, fontSize: 10)),
                      Text(
                        _nextPrayerName.isEmpty ? "--:--:--" : "$_nextPrayerName $_countdownString",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_dateString.toUpperCase(), style: const TextStyle(color: Colors.white60, fontSize: 10)),
                      Text(_cityString, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          _buildMenuGrid(),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> allMenus = [
      {'title': 'Al-Quran', 'icon': Icons.menu_book},
      {'title': 'Asmaul Husna', 'icon': Icons.phonelink_setup},
      {'title': 'Doa Harian', 'icon': Icons.auto_stories},
      {'title': 'Hadist', 'icon': Icons.menu_book_outlined},
      {'title': 'Waktu', 'icon': Icons.access_time},
      {'title': 'Kiblat', 'icon': Icons.explore},
      {'title': 'Calender', 'icon': Icons.calendar_month},
      {'title': 'Tasbih', 'icon': Icons.add_box},
      {'title': 'Menu', 'icon': Icons.grid_view_rounded},
    ];

    int itemCount = isExpanded ? allMenus.length : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final menu = allMenus[index];
        return GestureDetector(
          onTap: () {
            final title = menu['title'];
            if (title == 'Al-Quran') {
              if (widget.onQuranTap != null) {
                widget.onQuranTap!();
              }
            } else if (title == 'Asmaul Husna') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AsmaulHusnaPage()));
            } else if (title == 'Doa Harian') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaPage()));
            } else if (title == 'Hadist') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HadithPage()));
            } else if (title == 'Waktu') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SholatPage()));
            } else if (title == 'Kiblat') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const KiblatPage()));
            } else if (title == 'Calender') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
            } else if (title == 'Tasbih') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihPage()));
            } else if (title == 'Menu') {
              setState(() => isExpanded = !isExpanded);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(menu['icon'], size: 35, color: const Color(0xFF062743)),
              const SizedBox(height: 8),
              Text(menu['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimesRow() {
    final String subuh = todaySchedule['subuh'] ?? '04:42';
    final String dzuhur = todaySchedule['dzuhur'] ?? '11:52';
    final String ashar = todaySchedule['ashar'] ?? '15:10';
    final String magrib = todaySchedule['magrib'] ?? '17:51';
    final String isya = todaySchedule['isya'] ?? '19:01';

    final List<Map<String, String>> prayers = [
      {'name': 'Subuh', 'time': subuh, 'img': 'assets/gambar_subuh.jpg'},
      {'name': 'Dzuhur', 'time': dzuhur, 'img': 'assets/gambar_dzuhur.jpg'},
      {'name': 'Ashar', 'time': ashar, 'img': 'assets/gambar_ashar.jpg'},
      {'name': 'Magrib', 'time': magrib, 'img': 'assets/gambar_magrib.jpg'},
      {'name': 'Isya', 'time': isya, 'img': 'assets/gambar_isya.jpg'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((p) => _prayerItem(p['name']!, p['time']!, p['img']!)).toList(),
    );
  }

  Widget _prayerItem(String name, String time, String imagePath) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  static const Map<String, String> _staticBackupSchedule = {
    "tanggal": "Minggu, 14 Juni 2026",
    "imsak": "04:32",
    "subuh": "04:42",
    "terbit": "05:59",
    "dhuha": "06:27",
    "dzuhur": "11:52",
    "ashar": "15:10",
    "magrib": "17:51",
    "isya": "19:01"
  };
}