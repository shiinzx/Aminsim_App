import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 50, bottom: 100),
      children: [
        ListTile(title: Text("Settings")),
        ListTile(title: Text("Tentang App")),
      ],
    );
  }
}