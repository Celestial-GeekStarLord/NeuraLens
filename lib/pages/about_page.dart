import 'package:firstone/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ Drawer icon shows up here
        title: const Text("About Us", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.cyanAccent,
        ), // ← changes hamburger color
      ),
      drawer: const AppDrawer(),

      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  /// 🔹 App Icon + Title
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: _boxDecoration(),
                    child: const Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFF00E5FF), // Cyan accent
                          child: Icon(
                            Icons.memory,
                            size: 60,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'NeuraLens',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 207, 13, 13),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 About Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About This App',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'NeuraLens is an AI-powered vision and voice assistant. '
                          'It uses speech recognition, camera input, and Google\'s Gemini AI '
                          'to understand your queries and describe the world around you. '
                          'With integrated text-to-speech, it not only analyzes but also speaks '
                          'responses back to you — providing an accessible and futuristic experience.',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 Creator Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: const Column(
                      children: [
                        Text(
                          'Creator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color.fromARGB(
                            255,
                            85,
                            44,
                            201,
                          ), // Violet accent
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'NJ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 202, 8, 8),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Lead Engineer and Artist',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 Technologies Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technologies Used',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        ListTile(
                          leading: Icon(
                            Icons.flutter_dash,
                            color: Color(0xFF00E5FF),
                          ), // Cyan
                          title: Text(
                            'Flutter',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Cross-platform mobile development framework',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.mic,
                            color: Color(0xFF00E5FF),
                          ), // Cyan
                          title: Text(
                            'Speech-to-Text',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Converts spoken words into text queries',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.camera_alt,
                            color: Color(0xFF00E5FF),
                          ),
                          title: Text(
                            'Camera + Vision',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Captures real-world scenes for AI analysis',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF00E5FF),
                          ),
                          title: Text(
                            'Gemini AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Processes images & queries to generate insights',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.record_voice_over,
                            color: Color(0xFF00E5FF),
                          ),
                          title: Text(
                            'Text-to-Speech (TTS)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Reads AI responses aloud for accessibility',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _boxDecoration(),
                    child: const Column(
                      children: [
                        Text(
                          '© 2025 NeuraLens',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'All rights reserved',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Common Glassmorphism-style BoxDecoration
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
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
            leading: Icon(Icons.home, color: Colors.cyanAccent),
            title: Text("Home", style: TextStyle(color: Colors.cyanAccent)),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          ListTile(
            leading: Icon(Icons.menu_book, color: Colors.cyanAccent),
            title: Text("About Us", style: TextStyle(color: Colors.cyanAccent)),
            onTap: () => Navigator.pushNamed(context, "/about"),
          ),
          ListTile(
            leading: Icon(Icons.memory, color: Colors.cyanAccent),
            title: Text(
              "Neural Insights",
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onTap: () => Navigator.pushNamed(context, "/insights"),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.cyanAccent),
            title: Text("Settings", style: TextStyle(color: Colors.cyanAccent)),
            onTap: () => Navigator.pushNamed(context, "/settings"),
          ),
        ],
      ),
    );
  }
}
