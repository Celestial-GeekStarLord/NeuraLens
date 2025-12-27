import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _voiceEnabled = true;
  bool _cameraAssist = true; // kept for functionality consistency
  double _speechRate = 1.0;
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget control,
    required Color glowColor,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                glowColor.withOpacity(0.25),
                Colors.black.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, color: glowColor, size: 34),
            title: Text(
              title,
              style: TextStyle(
                color: glowColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.8,
              ),
            ),
            trailing: control,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Neuralens Settings"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade900.withOpacity(0.7),
                  Colors.black,
                  Colors.deepPurple.shade900.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_controller.value * 2 * math.pi),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AnimatedStarsPainter(_controller),
                  ),
                ),

                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: const [
                                  Colors.cyanAccent,
                                  Colors.purpleAccent,
                                  Colors.pinkAccent,
                                  Colors.blueAccent,
                                ],
                                transform: GradientRotation(
                                  _controller.value * 2 * math.pi,
                                ),
                              ).createShader(bounds),
                              child: const Text(
                                "AI & Accessibility Settings",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // 🎤 Single Describe Mode (Voice Assistant)
                            _buildSettingTile(
                              icon: Icons.record_voice_over_rounded,
                              title: "Describe Mode",
                              glowColor: Colors.cyanAccent,
                              control: Switch(
                                value: _voiceEnabled,
                                activeColor: Colors.cyanAccent,
                                onChanged: (v) =>
                                    setState(() => _voiceEnabled = v),
                              ),
                            ),

                            // 🔊 Speech Speed
                            _buildSettingTile(
                              icon: Icons.speed_rounded,
                              title: "Speech Speed",
                              glowColor: Colors.greenAccent,
                              control: SizedBox(
                                width: 120,
                                child: Slider(
                                  value: _speechRate,
                                  min: 0.5,
                                  max: 2.0,
                                  divisions: 6,
                                  activeColor: Colors.greenAccent,
                                  onChanged: (v) =>
                                      setState(() => _speechRate = v),
                                ),
                              ),
                            ),

                            // 🌙 Dark Mode
                            _buildSettingTile(
                              icon: Icons.dark_mode_rounded,
                              title: "Dark Mode",
                              glowColor: Colors.purpleAccent,
                              control: Switch(
                                value: _darkMode,
                                activeColor: Colors.purpleAccent,
                                onChanged: (v) => setState(() => _darkMode = v),
                              ),
                            ),

                            const Spacer(),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 30,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 10,
                                shadowColor: Colors.purpleAccent,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Settings saved successfully!",
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.save_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Save Settings",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 70),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 🌟 Animated stars in background
class _AnimatedStarsPainter extends CustomPainter {
  final Animation<double> animation;
  _AnimatedStarsPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final starCount = 30;
    final random = math.Random(42);

    for (int i = 0; i < starCount; i++) {
      final x = size.width * random.nextDouble();
      final y = size.height * random.nextDouble();
      final radius = (random.nextDouble() * 2) + 1;
      final hueShift = (animation.value * 360 + i * 12) % 360;
      final color = HSVColor.fromAHSV(
        0.6,
        hueShift,
        1.0,
        1.0,
      ).toColor().withOpacity(0.6);
      paint.color = color;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedStarsPainter oldDelegate) => true;
}
