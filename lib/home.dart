import 'dart:ui';
import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/quran_page.dart';
import 'pages/history_page.dart';
import 'pages/more_page.dart';
import 'pages/ai_chat_sheet.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        MenuPage(onQuranTap: () => _onTap(1)),
        const QuranPage(),
        const HistoryPage(),
        const MorePage(),
      ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _openAiChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiChatBottomSheet(),
    );
  }

  // Returns the background color of the currently active page — no sekat
  Color get _currentPageBg {
    switch (_currentIndex) {
      case 0:
        return const Color(0xFF030712); // MenuPage bottom gradient color
      case 1:
        return const Color(0xFF0F1621); // QuranPage background
      case 2:
        return const Color(0xFF0F1621); // HistoryPage background
      case 3:
        return const Color(0xFF0A0F24); // MorePage background
      default:
        return const Color(0xFF0F1621);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentPageBg,
      extendBody: true, // Body extends behind bottom nav — no sekat!

      body: Stack(
        children: [
          // Active page contents
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Glow effect behind bottom navigation bar and FAB
          Positioned(
            bottom: -10, // Centered behind the FAB
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 220,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.35),
                      Colors.amber.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ),

          // Floating Bottom Navigation Bar & FAB Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // The floating bottom nav bar card
                    _buildBottomNav(),

                    // The FAB floating in the center, overlapping the bar
                    Positioned(
                      top: -14, // slightly overlapping the top
                      child: GestureDetector(
                        onTap: _openAiChat,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPageBg, // Matches active page background!
                            border: Border.all(color: Colors.amber, width: 1.8), // Yellow/gold border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology, // yellow head-gear icon
                            size: 28,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // floats it above the bottom and sides!
      height: 68,
      decoration: BoxDecoration(
        color: _currentPageBg.withValues(alpha: 0.85), // translucent glassmorphic look
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Left: Menu
                Expanded(child: _navItem(Icons.grid_view_rounded, "Menu", 0)),
                // Left-center: Al-Quran
                Expanded(child: _navItem(Icons.menu_book_outlined, "Al-Quran", 1)),
                // Center gap for FAB
                const SizedBox(width: 70),
                // Right-center: History
                Expanded(child: _navItem(Icons.history_rounded, "History", 2)),
                // Right: More
                Expanded(child: _navItem(Icons.more_horiz, "More", 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? Colors.amber : Colors.white38,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.amber : Colors.white38,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}