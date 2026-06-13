import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: const Text("AMINSIM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Tombol History
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF062743),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text("HISTORY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 30),

            // 1. PRAYER TRACKER DETAILED
            _buildDetailedTracker("Today, 22 Mei"),
            const SizedBox(height: 20),
            _buildDetailedTracker("Yesterday, 21 Mei"),
            
            const SizedBox(height: 30),

            // 2. LAST READ QURAN (Tambahan Desain)
            _buildHistoryCard(
              title: "Last Read Al-Quran",
              icon: Icons.menu_book,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Al-Baqarah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Halaman 12", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. DAILY DOA HISTORY
            _buildHistoryCard(
              title: "Doa Harian",
              icon: Icons.auto_stories,
              child: const Text("15 Doa telah dibaca hari ini", style: TextStyle(color: Colors.blueGrey)),
            ),
            
            const SizedBox(height: 100), // Space untuk BottomNav
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTracker(String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PRAYER TRACKER - $date", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _trackerIcon("Subuh", true),
              _trackerIcon("Dzuhur", true),
              _trackerIcon("Ashar", true),
              _trackerIcon("Magrib", false),
              _trackerIcon("Isya", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trackerIcon(String label, bool isDone) {
    return Column(
      children: [
        Icon(Icons.check_circle, color: isDone ? const Color(0xFF062743) : Colors.white, size: 30),
        const SizedBox(height: 8),
        Container(
          width: 35, height: 18,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF062743) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF062743)),
          ),
          child: Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: isDone ? Colors.white : Colors.grey, shape: BoxShape.circle))),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHistoryCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF062743)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 25),
          child,
        ],
      ),
    );
  }
}