import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/quran_page.dart';
import 'pages/center_page.dart';
import 'pages/history_page.dart';
import 'pages/more_page.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    MenuPage(onQuranTap: () => _onTap(1)),
    QuranPage(),
    CenterPage(),
    HistoryPage(),
    MorePage(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _onCenterTap() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 75,
                decoration: BoxDecoration(
                  color: Color(0xFF062743),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    navItem(Icons.grid_view, "Menu", 0),
                    navItem(Icons.menu_book, "Al-Quran", 1),

                    SizedBox(width: 60),

                    navItem(Icons.history, "History", 3),
                    navItem(Icons.star, "More", 4),
                  ],
                ),
              ),

              Positioned(
                top: -30,
                child: GestureDetector(
                  onTap: _onCenterTap,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Color(0xFF1F3F68),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10)
                      ],
                    ),
                    child: Icon(Icons.mosque, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.amber : Colors.white),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.amber : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}