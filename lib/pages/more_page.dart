import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 50),
      children: [
        ListTile(title: Text("Settings")),
        ListTile(title: Text("Tentang App")),
      ],
    );
  }
}