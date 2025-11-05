import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.teal, Colors.black]),
            ),
            child: Text(
              "NeuraLens Menu",
              style: TextStyle(
                fontSize: 22,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.cyanAccent),
            title: const Text(
              "Home",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.cyanAccent),
            title: const Text(
              "About Us",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, "/about"),
          ),
          ListTile(
            leading: const Icon(Icons.memory, color: Colors.cyanAccent),
            title: const Text(
              "Neural Insights",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, "/insights"),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.cyanAccent),
            title: const Text(
              "Settings",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, "/settings"),
          ),
          ListTile(
            leading: const Icon(
              Icons.rocket_launch_sharp,
              color: Colors.cyanAccent,
            ),
            title: const Text(
              "Your Thoughts",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, "/feedback"),
          ),
        ],
      ),
    );
  }
}
