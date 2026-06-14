import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F24),
        elevation: 0,
        title: const Text(
          "Profile & Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 100),
        children: [
          _buildMoreTile(Icons.settings_outlined, "Settings"),
          _buildMoreTile(Icons.info_outline, "Tentang App"),
        ],
      ),
    );
  }

  Widget _buildMoreTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF132235),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF3B82F6)),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
          onTap: () {},
        ),
      ),
    );
  }
}