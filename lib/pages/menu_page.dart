import 'package:flutter/material.dart';
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
          const Center(
            child: Text(
              "20 : 00",
              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF062743),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("REMAIN TIME", style: TextStyle(color: Colors.white60, fontSize: 10)),
                      Text("Magrib 0:50:35", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("22 MEI, 2026", style: TextStyle(color: Colors.white60, fontSize: 10)),
                      Text("Cianjur, Indonesia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final List<Map<String, String>> prayers = [
      {'name': 'Subuh', 'time': '04:42', 'img': 'assets/gambar_subuh.jpg'},
      {'name': 'Dzuhur', 'time': '11:52', 'img': 'assets/gambar_dzuhur.jpg'},
      {'name': 'Ashar', 'time': '03:10', 'img': 'assets/gambar_ashar.jpg'},
      {'name': 'Magrib', 'time': '05:51', 'img': 'assets/gambar_magrib.jpg'},
      {'name': 'Isya', 'time': '07:01', 'img': 'assets/gambar_isya.jpg'},
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
}