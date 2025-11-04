import 'package:firstone/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ Drawer icon shows up here
        title: const Text("About Us"),
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text(
          "Settings page coming soon! Adjust AI, speech, and camera options here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
