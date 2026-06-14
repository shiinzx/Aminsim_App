import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1621), // Premium dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1621),
        elevation: 0,
        title: const Text(
          "HISTORY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // 1. PRAYER TRACKER DETAILED (Today)
            _buildDetailedTracker("Today, 22 Mei", [true, true, true, false, false]),
            const SizedBox(height: 20),
            
            // 2. PRAYER TRACKER DETAILED (Yesterday)
            _buildDetailedTracker("Yesterday, 21 Mei", [true, true, true, false, false]),
            const SizedBox(height: 25),

            // 3. LAST READ QURAN
            _buildHistoryCard(
              title: "Last Read Al-Quran",
              icon: Icons.menu_book,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Al-Baqarah",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Halaman 12",
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. DAILY DOA HISTORY
            _buildHistoryCard(
              title: "Doa Harian",
              icon: Icons.auto_stories,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "15 Doa telah dibaca hari ini",
                      style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(Icons.check_circle, size: 20, color: Colors.amber),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTracker(String date, List<bool> checklist) {
    final prayers = ["Subuh", "Dzuhur", "Ashar", "Magrib", "Isya"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2B), // Dark card background
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                "PRAYER TRACKER - ${date.toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(prayers.length, (i) {
              final isDone = checklist[i];
              return _trackerIcon(prayers[i], isDone);
            }),
          ),
        ],
      ),
    );
  }

  Widget _trackerIcon(String label, bool isDone) {
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? Colors.amber : Colors.white24,
          size: 28,
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 16,
          decoration: BoxDecoration(
            color: isDone ? Colors.amber.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDone ? Colors.amber : Colors.white24, width: 1),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isDone ? Colors.amber : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildHistoryCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181F2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.amber),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}