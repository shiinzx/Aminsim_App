import 'package:flutter/material.dart';

class CenterPage extends StatelessWidget {
  const CenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Jadwal Sholat", style: TextStyle(fontSize: 20)),
    );
  }
}