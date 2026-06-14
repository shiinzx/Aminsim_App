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

  Map<String, String> _getActivePrayerInfo() {
    final defaultInfo = {"name": "Dhuhur", "range": "11:52 - 15:10"};
    if (todaySchedule.isEmpty) return defaultInfo;

    try {
      final now = DateTime.now();
      final String subuh = todaySchedule['subuh'] ?? '04:42';
      final String dzuhur = todaySchedule['dzuhur'] ?? '11:52';
      final String ashar = todaySchedule['ashar'] ?? '15:10';
      final String magrib = todaySchedule['magrib'] ?? '17:51';
      final String isya = todaySchedule['isya'] ?? '19:01';

      final tSubuh = _parseTime(subuh, now);
      final tDzuhur = _parseTime(dzuhur, now);
      final tAshar = _parseTime(ashar, now);
      final tMagrib = _parseTime(magrib, now);
      final tIsya = _parseTime(isya, now);

      if (tSubuh == null || tDzuhur == null || tAshar == null || tMagrib == null || tIsya == null) {
        return defaultInfo;
      }

      if (now.isBefore(tSubuh)) {
        return {"name": "Isya", "range": "$isya - $subuh"};
      } else if (now.isBefore(tDzuhur)) {
        return {"name": "Subuh", "range": "$subuh - $tDzuhur"};
      } else if (now.isBefore(tAshar)) {
        return {"name": "Dzuhur", "range": "$dzuhur - $ashar"};
      } else if (now.isBefore(tMagrib)) {
        return {"name": "Ashar", "range": "$ashar - $magrib"};
      } else if (now.isBefore(tIsya)) {
        return {"name": "Magrib", "range": "$magrib - $isya"};
      } else {
        return {"name": "Isya", "range": "$isya - $subuh"};
      }
    } catch (e) {
      return defaultInfo;
    }
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
            Color(0xFF0F172A),
            Color(0xFF070B16),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpandableMenu(),
                  const SizedBox(height: 25),
                  const Text(
                    "Jadwal Sholat",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPrayerTimesRow(),
                  const SizedBox(height: 12),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for App Title/Logo, Notifications, Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "MusP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.explore_outlined, color: Colors.blue[400], size: 20),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Subtitle
          Text(
            "$_dateString | Stay Notified. 🌙",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Location Selector card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.my_location, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text(
                  _cityString,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Large digital clock
          Center(
            child: Column(
              children: [
                Text(
                  _timeString,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                if (_nextPrayerName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Next: $_nextPrayerName in $_countdownString",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Active Prayer Banner
          _buildActivePrayerBanner(),
        ],
      ),
    );
  }

  Widget _buildActivePrayerBanner() {
    final activeInfo = _getActivePrayerInfo();
    final String name = activeInfo['name']!;
    final String range = activeInfo['range']!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                range,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.volume_up_outlined, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.more_vert, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: _buildMenuGrid(),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> allMenus = [
      {'title': 'Al-Quran', 'icon': Icons.menu_book},
      {'title': 'Asmaul Husna', 'icon': Icons.phonelink_setup},
      {'title': 'Alif Ba Ta', 'icon': Icons.translate},
      {'title': 'Doa Harian', 'icon': Icons.auto_stories},
      {'title': 'Hadist', 'icon': Icons.menu_book_outlined},
      {'title': 'Waktu', 'icon': Icons.access_time},
      {'title': 'Kiblat', 'icon': Icons.explore},
      {'title': 'Calender', 'icon': Icons.calendar_month},
      {'title': 'Tasbih', 'icon': Icons.add_box},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: allMenus.length,
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
            } else if (title == 'Alif Ba Ta') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AlifBaTaPage()));
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
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(menu['icon'], size: 26, color: const Color(0xFF3B82F6)),
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

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
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
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: Colors.amber, size: 20),
        ),
        const SizedBox(height: 8),
        Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildExtraTimesRow() {
    final String imsak = todaySchedule['imsak'] ?? '04:32';
    final String terbit = todaySchedule['terbit'] ?? '05:59';
    final String dhuha = todaySchedule['dhuha'] ?? '06:27';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _extraTimeCol("Imsak", imsak),
          _extraTimeCol("Terbit", terbit),
          _extraTimeCol("Dhuha", dhuha),
        ],
      ),
    );
  }

  Widget _extraTimeCol(String label, String time) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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