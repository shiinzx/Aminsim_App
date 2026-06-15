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
        return const Color(0xFF070B16); // MenuPage
      case 1:
        return const Color(0xFF0F1621); // QuranPage
      case 2:
        return const Color(0xFF0F1621); // HistoryPage
      case 3:
        return const Color(0xFF0F1621); // MorePage
      default:
        return const Color(0xFF0F1621);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentPageBg,
      extendBody: true, // Body extends behind bottom nav — no sekat!

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: GestureDetector(
        onTap: _openAiChat,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE8A020), Color(0xFFC07010)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.55),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            size: 26,
            color: Colors.white,
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            // Seamless: background matches the current page, with blur glass
            color: _currentPageBg.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Left: Menu
              Expanded(child: _navItem(Icons.grid_view_rounded, "Menu", 0)),
              // Left-center: Al-Quran
              Expanded(child: _navItem(Icons.menu_book_outlined, "Al-Quran", 1)),
              // Center gap for FAB
              const SizedBox(width: 72),
              // Right-center: History
              Expanded(child: _navItem(Icons.history_rounded, "History", 2)),
              // Right: More
              Expanded(child: _navItem(Icons.more_horiz, "More", 3)),
            ],
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              size: 23,
              color: isActive ? Colors.amber : Colors.white38,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: isActive ? Colors.amber : Colors.white38,
              fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}