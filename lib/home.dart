import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/sholat_page.dart';
import 'pages/quran_page.dart';
import 'pages/planner_page.dart';
import 'pages/more_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    MenuPage(onQuranTap: () => _onTap(2)), // Directs to Book tab
    const SholatPage(),
    const QuranPage(),
    const PlannerPage(),
    const MorePage(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F24),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF090F1E),
          border: Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(Icons.home, Icons.home_outlined, "Home", 0),
              navItem(Icons.access_time_filled, Icons.access_time_outlined, "Prayers", 1),
              navItem(Icons.menu_book, Icons.menu_book_outlined, "Book", 2),
              navItem(Icons.checklist, Icons.checklist_outlined, "Planner", 3),
              navItem(Icons.person, Icons.person_outline, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? const Color(0xFF3B82F6) : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF3B82F6) : Colors.white70,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}