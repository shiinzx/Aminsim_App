import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'asmaul_husna_page.dart';
import 'doa_page.dart';
import 'hadith_page.dart';
import 'sholat_page.dart';
import 'kiblat_page.dart';
import 'tasbih_page.dart';
import 'calendar_page.dart';
import 'alif_ba_ta_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onQuranTap;
  const MenuPage({super.key, this.onQuranTap});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isExpanded = false;
  Timer? _timer;
  String _timeString = "--:--:-- --";
  String _countdownString = "--:--:--";
  String _nextPrayerName = "";
  String _dateString = "";
  String _cityString = "Cianjur, Indonesia";
  String _cityId = "1206"; // Default city ID for Kabupaten Cianjur in myquran API
  Map<String, dynamic> todaySchedule = {};
  bool isLoadingPrayer = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeAndCountdown();
    });
    _updateTimeAndCountdown();
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _fetchTodayPrayerTimes() async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    Position? position;
    try {
      position = await _determinePosition();
    } catch (e) {
      position = null;
    }

    if (position != null) {
      try {
        final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10';
        final geoResponse = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': 'AminsimApp/1.0'},
        );
        if (geoResponse.statusCode == 200) {
          final geoData = json.decode(geoResponse.body);
          final address = geoData['address'] ?? {};
          String detectedCity = address['county'] ?? address['city'] ?? address['town'] ?? address['municipality'] ?? address['state_district'] ?? 'Cianjur';
          
          detectedCity = detectedCity
              .replaceAll(RegExp(r'(Kabupaten|Kab\.|Kota|Kecamatan|District)\s*', caseSensitive: false), '')
              .trim();

          final searchResponse = await http.get(Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/$detectedCity'));
          if (searchResponse.statusCode == 200) {
            final searchData = json.decode(searchResponse.body);
            if (searchData['status'] == true && searchData['data'] != null && (searchData['data'] as List).isNotEmpty) {
              _cityId = searchData['data'][0]['id'];
              _cityString = "${searchData['data'][0]['lokasi']}, Indonesia";
            }
          }
        }
      } catch (e) {
        // Fallback silently
      }
    }

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
      } else {
        _useFallbackSchedule();
      }
    } catch (e) {
      _useFallbackSchedule();
    }
  }

  void _useFallbackSchedule() {
    if (mounted) {
      setState(() {
        todaySchedule = _staticBackupSchedule;
        _cityString = "Cianjur, Indonesia";
        isLoadingPrayer = false;
      });
      _updateTimeAndCountdown();
    }
  }

  void _updateTimeAndCountdown() {
    try {
      final now = DateTime.now();
      
      // Clock update with seconds and AM/PM
      final hourInt = now.hour;
      final isAm = hourInt < 12;
      final displayHour = hourInt == 0 ? 12 : (hourInt > 12 ? hourInt - 12 : hourInt);
      final hourStr = displayHour.toString().padLeft(2, '0');
      final minuteStr = now.minute.toString().padLeft(2, '0');
      final secondStr = now.second.toString().padLeft(2, '0');
      final ampm = isAm ? "am" : "pm";
      final timeStr = "$hourStr:$minuteStr:$secondStr $ampm";

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
    } catch (e) {
      // Safety wrapper
    }
  }

  DateTime? _parseTime(String? timeStr, DateTime date) {
    try {
      if (timeStr == null || !timeStr.contains(':')) return null;
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  String _getFormattedDate(DateTime date) {
    final days = ["Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"];
    final months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0F24), // Premium dark blue
            Color(0xFF030712), // Deep black-blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Mosque Silhouette centered in the middle-upper area of screen background
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.18, // transparent subtle silhouette matching first mockup image
              child: Image.asset(
                'assets/mosque_silhouette.png',
                fit: BoxFit.cover,
                height: 280,
              ),
            ),
          ),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120), // padding bottom for floating bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpandableMenu(),
                      const SizedBox(height: 30),
                      const Text(
                        "Jadwal Sholat",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildPrayerTimesRow(),
                      const SizedBox(height: 15),
                      _buildExtraTimesRow(),
                      const SizedBox(height: 25),
                      const Text(
                        "Prayer Tracker",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerSlide(String day) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PRAYER TRACKER - $day", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white70, letterSpacing: 1.1)),
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
              Container(width: 6, height: 6, decoration: BoxDecoration(color: day == "Today" ? Colors.blue : Colors.grey, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: day == "Yesterday" ? Colors.blue : Colors.grey, shape: BoxShape.circle)),
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.check_circle,
        color: isDone ? const Color(0xFF3B82F6) : Colors.white24,
        size: 20,
      ),
    );
  }

  Widget _buildHeader() {
    final parts = _timeString.split(':');
    final displayTime = parts.length >= 2 ? "${parts[0]}:${parts[1]}" : "--:--";

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Title & Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AminSim", // Matching mockup exactly
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Clock in the center
            Text(
              displayTime,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            // Countdown & Location Bar (Status Bar) - Transparent background, matches mockup
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Remain Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "REMAIN TIME",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _nextPrayerName.isNotEmpty
                          ? "$_nextPrayerName $_countdownString"
                          : "Next prayer --:--",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Right: Date & Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _dateString.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _cityString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableMenu() {
    return Column(
      children: [
        _buildMenuGrid(),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 32,
            color: Colors.amber,
          ),
        ),
      ],
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
      {'title': 'Alif Ba Ta', 'icon': Icons.translate},
      {'title': 'Calender', 'icon': Icons.calendar_month},
      {'title': 'Tasbih', 'icon': Icons.add_box},
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
            } else if (title == 'Alif Ba Ta') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AlifBaTaPage()));
            } else if (title == 'Calender') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
            } else if (title == 'Tasbih') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihPage()));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.6), // dark blue-grey circle
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
                ),
                child: Icon(menu['icon'], size: 24, color: const Color(0xFF60A5FA)), // light blue icon
              ),
              const SizedBox(height: 8),
              Text(menu['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _prayerItem('Subuh', subuh, Icons.wb_twilight_outlined),
          _prayerItem('Dzuhur', dzuhur, Icons.wb_sunny_outlined),
          _prayerItem('Ashar', ashar, Icons.wb_cloudy_outlined),
          _prayerItem('Magrib', magrib, Icons.wb_twilight),
          _prayerItem('Isya', isya, Icons.nightlight_round_outlined),
        ],
      ),
    );
  }

  Widget _prayerItem(String name, String time, IconData icon) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B).withValues(alpha: 0.6),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(icon, color: Colors.amber, size: 20),
        ),
        const SizedBox(height: 8),
        Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildExtraTimesRow() {
    final String imsak = todaySchedule['imsak'] ?? '04:20';
    final String dhuha = todaySchedule['dhuha'] ?? '05:26';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _extraTimeCol("Imsak", imsak),
        const SizedBox(width: 140), // Centered gap to avoid the FAB and its glow
        _extraTimeCol("Dhuha", dhuha),
      ],
    );
  }

  Widget _extraTimeCol(String label, String time) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  static const Map<String, String> _staticBackupSchedule = {
    "tanggal": "Minggu, 14 Juni 2026",
    "imsak": "04:20",
    "subuh": "04:39",
    "terbit": "05:59",
    "dhuha": "05:26",
    "dzuhur": "11:55",
    "ashar": "15:16",
    "magrib": "17:51",
    "isya": "19:01"
  };
}